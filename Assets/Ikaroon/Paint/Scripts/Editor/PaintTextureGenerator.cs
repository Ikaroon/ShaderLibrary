using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace Ikaroon.PaintEditor
{
	public class PaintTextureGenerator : EditorWindow
	{
		static int s_brushTexID = Shader.PropertyToID("_BrushTex");
		static int s_brushBoundsID = Shader.PropertyToID("_BrushBounds");
		static int s_brushRotationID = Shader.PropertyToID("_BrushRotation");
		static int s_noiseTexID = Shader.PropertyToID("_NoiseTex");
		static int s_noiseStrengthID = Shader.PropertyToID("_NoiseStrength");

		Mesh m_mesh;
		Vector2Int m_size = new Vector2Int(256, 256);
		int m_bleed = 4;
		int m_brushSteps = 32;
		Vector2 m_brushOffset = new Vector2(0f, 1f);
		Vector2 m_brushStretchX = new Vector2(0.75f, 1f);
		Vector2 m_brushStretchY = new Vector2(0f, 0.25f);
		float m_noiseStrength = 1;

		Material m_toTextureMaterial;
		Material m_bleedMaterial;
		Material m_brushMaterial;
		Material m_brushColorMaterial;

		Texture m_noiseTexture;
		Texture m_brushTexture;

		RenderTexture m_normalTexture;
		RenderTexture m_colorTexture;

		List<int> m_indexX = new List<int>();
		List<int> m_indexY = new List<int>();

		[MenuItem("Window/Ikaroon/Paint/Texture Generator")]
		public static void Init()
		{
			var window = EditorWindow.GetWindow<PaintTextureGenerator>();
		}

		private void OnGUI()
		{
			m_mesh = EditorGUILayout.ObjectField("Mesh", m_mesh, typeof(Mesh), false) as Mesh;
			m_size = EditorGUILayout.Vector2IntField("Size", m_size);
			m_bleed = EditorGUILayout.IntField("Bleed", m_bleed);

			EditorGUILayout.Space();
			m_brushTexture = EditorGUILayout.ObjectField("Brush Texture", m_brushTexture, typeof(Texture), false) as Texture;
			m_brushSteps = EditorGUILayout.IntField("Brush Steps", m_brushSteps);
			EditorGUILayout.MinMaxSlider("Brush Offset", ref m_brushOffset.x, ref m_brushOffset.y, 0f, 1f);
			EditorGUILayout.MinMaxSlider("Brush Stretch X", ref m_brushStretchX.x, ref m_brushStretchX.y, 0f, 1f);
			EditorGUILayout.MinMaxSlider("Brush Stretch Y", ref m_brushStretchY.x, ref m_brushStretchY.y, 0f, 1f);

			EditorGUILayout.Space();
			m_noiseTexture = EditorGUILayout.ObjectField("Noise Texture", m_noiseTexture, typeof(Texture), false) as Texture;
			m_noiseStrength = EditorGUILayout.Slider("Noise Strength", m_noiseStrength, 0f, 1f);

			if (GUILayout.Button("Generate") && m_mesh != null)
			{
				Generate(m_mesh);
			}

			EditorGUILayout.BeginHorizontal();
			if (GUILayout.Button("Save Normals") && m_normalTexture != null)
			{
				Save(m_normalTexture);
			}
			if (GUILayout.Button("Save Colors") && m_colorTexture != null)
			{
				Save(m_colorTexture);
			}
			EditorGUILayout.EndHorizontal();

			if (m_normalTexture != null)
			{
				var width = position.width - 30f;
				var rect = GUILayoutUtility.GetRect(width, width);
				rect.width = width * 0.5f;
				rect.height = width * 0.5f;
				rect.x += 10f;
				rect.y += 10f;
				GUI.DrawTexture(rect, m_normalTexture);
				rect.x += width * 0.5f + 10f;
				GUI.DrawTexture(rect, m_colorTexture);
			}
		}

		void OnEnable()
		{
			var shader = Shader.Find("Hidden/Ikaroon/MeshToObjectNormalTexture");
			m_toTextureMaterial = new Material(shader);

			var bleedShader = Shader.Find("Hidden/Ikaroon/BleedObjectNormalTexture");
			m_bleedMaterial = new Material(bleedShader);

			var brushShader = Shader.Find("Hidden/Ikaroon/BrushToObjectNormalTexture");
			m_brushMaterial = new Material(brushShader);

			var brushColorShader = Shader.Find("Hidden/Ikaroon/BrushToColorTexture");
			m_brushColorMaterial = new Material(brushColorShader);
		}

		void OnDisable()
		{
			if (m_normalTexture != null)
			{
				m_normalTexture.Release();
				m_normalTexture = null;
			}

			if (m_toTextureMaterial != null)
				DestroyImmediate(m_toTextureMaterial);

			if (m_bleedMaterial != null)
				DestroyImmediate(m_bleedMaterial);

			if (m_brushMaterial != null)
				DestroyImmediate(m_brushMaterial);
		}

		static void Shuffle<T>(IList<T> list)
		{
			for (int i  = 0; i < list.Count - 1; i++)
			{
				var index = Random.Range(i + 1, list.Count - 1);
				var temp = list[i];
				list[i] = list[index];
				list[index] = temp;
			}
		}

		void Generate(Mesh mesh)
		{
			if (m_normalTexture != null)
			{
				m_normalTexture.Release();
				m_normalTexture = null;
			}

			m_normalTexture = new RenderTexture(m_size.x, m_size.y, 0);
			m_normalTexture.filterMode = FilterMode.Point;
			m_normalTexture.wrapMode = TextureWrapMode.Clamp;

			m_colorTexture = new RenderTexture(m_size.x, m_size.y, 0);
			m_colorTexture.filterMode = FilterMode.Point;
			m_colorTexture.wrapMode = TextureWrapMode.Clamp;

			var oldRT = RenderTexture.active;
			RenderTexture.active = m_normalTexture;

			GL.Clear(true, true, Color.black);
			m_toTextureMaterial.SetPass(0);
			Graphics.DrawMeshNow(mesh, Vector3.zero, Quaternion.identity, 0);

			RenderTexture.active = m_colorTexture;

			GL.Clear(true, true, Color.white);

			RenderTexture.active = oldRT;

			m_indexX.Clear();
			m_indexY.Clear();

			for (int x = 0; x < m_brushSteps; x++)
				m_indexX.Add(x);

			for (int y = 0; y < m_brushSteps; y++)
				m_indexY.Add(y);

			Shuffle(m_indexX);
			Shuffle(m_indexY);

			var halfSteps = m_brushSteps * 0.5f;
			var size = new Vector2(m_size.x / halfSteps, m_size.y / halfSteps);
			size.x /= m_size.x;
			size.y /= m_size.y;
			for (int x = 0; x < m_brushSteps; x++)
			{
				for (int y = 0; y < m_brushSteps; y++)
				{
					var raX = m_indexX[x];
					var raY = m_indexX[y];

					var baseX = (raX / (float)m_brushSteps) + Random.Range(-0.01f, 0.01f) * m_brushOffset.x;
					var baseY = (raY / (float)m_brushSteps) + Random.Range(-0.01f, 0.01f) * m_brushOffset.y;
					var rX = Random.Range(0.1f * m_brushStretchX.x, 0.1f * m_brushStretchX.y);
					var rY = Random.Range(0.1f * m_brushStretchY.x, 0.1f * m_brushStretchY.y);
					var bounds = new Vector4(baseX - rX, baseY - rY, baseX + size.x + rX, baseY + size.y + rY);
					var rotation = Matrix4x4.Rotate(Quaternion.Euler(0f, 0f, Random.Range(0f, 360f)));

					m_brushMaterial.SetTexture(s_brushTexID, m_brushTexture);
					m_brushMaterial.SetVector(s_brushBoundsID, bounds);
					m_brushMaterial.SetMatrix(s_brushRotationID, rotation);

					m_brushMaterial.SetTexture(s_noiseTexID, m_noiseTexture);
					m_brushMaterial.SetFloat(s_noiseStrengthID, m_noiseStrength);

					var temp = RenderTexture.GetTemporary(m_normalTexture.descriptor);
					Graphics.Blit(m_normalTexture, temp, m_brushMaterial);
					Graphics.Blit(temp, m_normalTexture);
					RenderTexture.ReleaseTemporary(temp);


					m_brushColorMaterial.SetTexture(s_brushTexID, m_brushTexture);
					m_brushColorMaterial.SetVector(s_brushBoundsID, bounds);
					m_brushColorMaterial.SetMatrix(s_brushRotationID, rotation);

					m_brushColorMaterial.SetTexture(s_noiseTexID, m_noiseTexture);
					m_brushColorMaterial.SetFloat(s_noiseStrengthID, m_noiseStrength);

					temp = RenderTexture.GetTemporary(m_colorTexture.descriptor);
					Graphics.Blit(m_colorTexture, temp, m_brushColorMaterial);
					Graphics.Blit(temp, m_colorTexture);
					RenderTexture.ReleaseTemporary(temp);
				}
			}

			for (int i = 0; i < m_bleed; i++)
			{
				var temp = RenderTexture.GetTemporary(m_normalTexture.descriptor);
				Graphics.Blit(m_normalTexture, temp, m_bleedMaterial);
				Graphics.Blit(temp, m_normalTexture);
				RenderTexture.ReleaseTemporary(temp);
			}
		}

		void Save(RenderTexture texture)
		{
			var path = EditorUtility.SaveFilePanel("Save Texture", "", "texture", "png");

			if (string.IsNullOrEmpty(path))
				return;

			var tex2D = new Texture2D(texture.width, texture.height, texture.graphicsFormat, TextureCreationFlags.None);
			tex2D.wrapMode = TextureWrapMode.Clamp;
			tex2D.filterMode = FilterMode.Bilinear;

			var oldRT = RenderTexture.active;
			RenderTexture.active = texture;

			tex2D.ReadPixels(new Rect(0, 0, tex2D.width, tex2D.height), 0, 0);
			tex2D.Apply();

			var png = tex2D.EncodeToPNG();
			DestroyImmediate(tex2D);

			System.IO.File.WriteAllBytes(path, png);

			RenderTexture.active = oldRT;
		}
	}
}

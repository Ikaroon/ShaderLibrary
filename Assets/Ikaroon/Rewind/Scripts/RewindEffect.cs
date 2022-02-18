using UnityEngine;

namespace Ikaroon.Rewind
{
	public class RewindEffect : MonoBehaviour
	{
		private const string SHADER_NAME = "Hidden/Ikaroon/Rewind";

		private Material m_mat;

		public float LineSize { get { return m_lineSize; } set { m_lineSize = value; } }
		[SerializeField]
		private float m_lineSize = 5f;

		public Vector2 WaveSize { get { return m_waveSize; } set { m_waveSize = value; } }
		[SerializeField]
		private Vector2 m_waveSize = new Vector2(5f, 5f);

		public float WaveSpeed { get { return m_waveSpeed; } set { m_waveSpeed = value; } }
		[SerializeField]
		private float m_waveSpeed = 1f;

		public float WaveStrength { get { return m_waveStrength; } set { m_waveStrength = value; } }
		[SerializeField]
		private float m_waveStrength = 1f;

		private void Start()
		{
			m_mat = new Material(Shader.Find(SHADER_NAME));
		}

		private void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			m_mat.SetFloat("_LineSize", m_lineSize);
			m_mat.SetFloat("_WaveSizeX", m_waveSize.x);
			m_mat.SetFloat("_WaveSizeY", m_waveSize.y);
			m_mat.SetFloat("_WaveSpeed", m_waveSpeed);
			m_mat.SetFloat("_WaveApply", m_waveStrength);
			Graphics.Blit(source, destination, m_mat);
		}
	}
}

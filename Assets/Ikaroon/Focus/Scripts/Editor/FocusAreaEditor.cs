using UnityEngine;
using UnityEditor;
using Ikaroon.Focus;

namespace Ikaroon.FocusEditor
{
	[CustomEditor(typeof(FocusArea))]
	public class FocusAreaEditor : Editor
	{

		#region Styles

		private GUIStyle m_styleBox, m_styleHeader;

		void InitStyles()
		{
			m_styleBox = new GUIStyle(GUI.skin.GetStyle("GroupBox"));

			m_styleHeader = new GUIStyle(GUI.skin.GetStyle("BoldLabel"));
		}

		#endregion Styles

		private FocusArea m_focusArea;

		private void OnEnable()
		{
			m_focusArea = (FocusArea)target;
		}

		public override void OnInspectorGUI()
		{
			if (m_styleBox == null)
			{
				InitStyles();
			}

			EditorGUILayout.BeginVertical(m_styleBox);

			EditorGUILayout.LabelField("Settings", m_styleHeader);
			m_focusArea.FocusBounds = EditorGUILayout.BoundsField(m_focusArea.FocusBounds);
			EditorGUILayout.EndVertical();


			EditorGUILayout.BeginVertical(m_styleBox);
			m_focusArea.e_edit = EditorGUILayout.BeginToggleGroup("Scene Edit", m_focusArea.e_edit);

			if (m_focusArea.e_edit)
			{
				m_focusArea.e_targetBoundsColor = EditorGUILayout.ColorField("Target Bounds", m_focusArea.e_targetBoundsColor);
				if (GUILayout.Button("Focus Area"))
				{
					m_focusArea.Focus();
				}
			}

			EditorGUILayout.EndToggleGroup();
			EditorGUILayout.EndVertical();
		}



		public void OnSceneGUI()
		{
			if (m_focusArea.e_edit)
			{
				Vector3 center = m_focusArea.FocusBounds.center;
				Vector3 size = m_focusArea.FocusBounds.size;

				EditorGUI.BeginChangeCheck();

				size.x = CubeHandle(ref center, new Vector3(size.x * 0.5f, 0f, 0f));
				size.x = CubeHandle(ref center, new Vector3(size.x * -0.5f, 0f, 0f));

				size.y = CubeHandle(ref center, new Vector3(0f, size.y * 0.5f, 0f));
				size.y = CubeHandle(ref center, new Vector3(0f, size.y * -0.5f, 0f));

				size.z = CubeHandle(ref center, new Vector3(0f, 0f, size.z * 0.5f));
				size.z = CubeHandle(ref center, new Vector3(0f, 0f, size.z * -0.5f));

				if (EditorGUI.EndChangeCheck())
				{
					m_focusArea.FocusBounds = new Bounds(center, size);
				}
			}

		}

		float CubeHandle(ref Vector3 center, Vector3 size)
		{
			Vector3 endA = center + size;
			Vector3 endB = center - size;
			endA = Handles.FreeMoveHandle(endA + m_focusArea.transform.position, Quaternion.identity, HandleUtility.GetHandleSize(endA + m_focusArea.transform.position) * 0.05f, new Vector3(0f, 0f, 0f), Handles.CubeHandleCap) - m_focusArea.transform.position;

			Vector3 scaleVector = new Vector3(Mathf.Abs(Mathf.Sign(size.x)), Mathf.Abs(Mathf.Sign(size.y)), Mathf.Abs(Mathf.Sign(size.z)));

			endA.Scale(scaleVector);

			Vector3 nEndB = endB;
			nEndB.Scale(scaleVector);
			Vector3 nCenter = center;
			nCenter.Scale(scaleVector);

			float nSize = Vector3.Distance(endA, nEndB);

			center = endB + (center - endB).normalized * (nSize / 2f);

			return nSize;
		}
	}
}
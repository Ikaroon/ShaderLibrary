using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Ikaroon.Focus
{
	[CustomEditor(typeof(FocusArea))]
	public class FocusAreaEditor : Editor
	{

		#region Styles

		private GUIStyle styleBox, styleHeader;

		void InitStyles()
		{
			styleBox = new GUIStyle(GUI.skin.GetStyle("GroupBox"));

			styleHeader = new GUIStyle(GUI.skin.GetStyle("BoldLabel"));
		}

		#endregion Styles

		private FocusArea focusArea;

		private void OnEnable()
		{
			focusArea = (FocusArea)target;
		}

		public override void OnInspectorGUI()
		{
			if (styleBox == null)
			{
				InitStyles();
			}

			EditorGUILayout.BeginVertical(styleBox);

			EditorGUILayout.LabelField("Settings", styleHeader);
			focusArea.focusBounds = EditorGUILayout.BoundsField(focusArea.focusBounds);
			EditorGUILayout.EndVertical();


			EditorGUILayout.BeginVertical(styleBox);
			focusArea.e_edit = EditorGUILayout.BeginToggleGroup("Scene Edit", focusArea.e_edit);

			if (focusArea.e_edit)
			{
				focusArea.e_targetBoundsColor = EditorGUILayout.ColorField("Target Bounds", focusArea.e_targetBoundsColor);
				if (GUILayout.Button("Focus Area"))
				{
					focusArea.Focus();
				}
			}

			EditorGUILayout.EndToggleGroup();
			EditorGUILayout.EndVertical();
		}



		public void OnSceneGUI()
		{
			if (focusArea.e_edit)
			{
				Vector3 center = focusArea.focusBounds.center;
				Vector3 size = focusArea.focusBounds.size;

				EditorGUI.BeginChangeCheck();

				size.x = CubeHandle(ref center, new Vector3(size.x * 0.5f, 0f, 0f));
				size.x = CubeHandle(ref center, new Vector3(size.x * -0.5f, 0f, 0f));

				size.y = CubeHandle(ref center, new Vector3(0f, size.y * 0.5f, 0f));
				size.y = CubeHandle(ref center, new Vector3(0f, size.y * -0.5f, 0f));

				size.z = CubeHandle(ref center, new Vector3(0f, 0f, size.z * 0.5f));
				size.z = CubeHandle(ref center, new Vector3(0f, 0f, size.z * -0.5f));

				if (EditorGUI.EndChangeCheck())
				{
					focusArea.focusBounds = new Bounds(center, size);
				}
			}

		}

		float CubeHandle(ref Vector3 center, Vector3 size)
		{
			Vector3 endA = center + size;
			Vector3 endB = center - size;
			endA = Handles.FreeMoveHandle(endA + focusArea.transform.position, Quaternion.identity, HandleUtility.GetHandleSize(endA + focusArea.transform.position) * 0.05f, new Vector3(0f, 0f, 0f), Handles.CubeHandleCap) - focusArea.transform.position;

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
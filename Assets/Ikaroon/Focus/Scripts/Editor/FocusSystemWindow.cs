using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Ikaroon.Focus
{
	public class FocusSystemWindow : EditorWindow
	{

		#region Styles

		private GUIStyle styleBox, styleHeader;

		void InitStyles()
		{
			styleBox = new GUIStyle(GUI.skin.GetStyle("GroupBox"));

			styleHeader = new GUIStyle(GUI.skin.GetStyle("BoldLabel"));
		}

		#endregion Styles

		private static FocusSystem data;

		[MenuItem("Tools/Ikaroon/Focus Settings", priority = 21)]
		static void Init()
		{
			FocusSystemWindow window = CreateInstance<FocusSystemWindow>();
			window.ShowUtility();
			window.minSize = new Vector2(400f, 200f);
			data = FocusSystem.DATA;
		}

		void OnEnable()
		{
			this.titleContent = new GUIContent("Focus Settings");
		}

		void OnGUI()
		{
			if (styleBox == null)
			{
				InitStyles();
			}

			if (data == null)
			{
				data = FocusSystem.DATA;
			}

			EditorGUI.BeginChangeCheck();

			EditorGUILayout.BeginVertical(styleBox);

			EditorGUILayout.LabelField("Settings", styleHeader);
			data.focusDuration = EditorGUILayout.FloatField("Focus Duration", Mathf.Max(0f, data.focusDuration));
			data.boundsOffset = EditorGUILayout.FloatField("Bounds Offset", Mathf.Max(0f, data.boundsOffset));

			EditorGUILayout.EndVertical();


			EditorGUILayout.BeginVertical(styleBox);
			data.e_debug = EditorGUILayout.BeginToggleGroup("Edit", data.e_debug);

			if (data.e_debug)
			{
				data.e_oldBoundsColor = EditorGUILayout.ColorField("Old Bounds", data.e_oldBoundsColor);
				data.e_newBoundsColor = EditorGUILayout.ColorField("New Bounds", data.e_newBoundsColor);
			}

			EditorGUILayout.EndToggleGroup();
			EditorGUILayout.EndVertical();

			if (EditorGUI.EndChangeCheck())
			{
				EditorUtility.SetDirty(data);
			}
		}

		void OnFocus()
		{
			// Remove delegate listener if it has previously
			// been assigned.
			SceneView.onSceneGUIDelegate -= this.OnSceneGUI;
			// Add (or re-add) the delegate.
			SceneView.onSceneGUIDelegate += this.OnSceneGUI;
		}

		void OnDestroy()
		{
			SceneView.onSceneGUIDelegate -= this.OnSceneGUI;
		}

		public void OnSceneGUI(SceneView sceneView)
		{
			if (data == null)
			{
				data = FocusSystem.DATA;
			}

			if (data.e_debug)
			{
				Vector3 oCenter = FocusSystem.oldFocusBounds.center;
				Vector3 oSize = FocusSystem.oldFocusBounds.size;

				Vector3 nCenter = FocusSystem.focusedBounds.center;
				Vector3 nSize = FocusSystem.focusedBounds.size;

				Color oldColor = Handles.color;

				Handles.color = data.e_oldBoundsColor;
				Handles.DrawWireCube(oCenter, oSize);

				Handles.color = data.e_newBoundsColor;
				Handles.DrawWireCube(nCenter, nSize);

				Handles.color = oldColor;
			}

		}
	}
}
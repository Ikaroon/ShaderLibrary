using UnityEngine;
using UnityEditor;
using Ikaroon.Focus;

namespace Ikaroon.FocusEditor
{
	public class FocusSystemWindow : EditorWindow
	{

		#region Styles

		private GUIStyle m_styleBox, m_styleHeader;

		void InitStyles()
		{
			m_styleBox = new GUIStyle(GUI.skin.GetStyle("GroupBox"));

			m_styleHeader = new GUIStyle(GUI.skin.GetStyle("BoldLabel"));
		}

		#endregion Styles

		private static FocusSystem s_data;

		[MenuItem("Tools/Ikaroon/Focus Settings", priority = 21)]
		static void Init()
		{
			FocusSystemWindow window = CreateInstance<FocusSystemWindow>();
			window.ShowUtility();
			window.minSize = new Vector2(400f, 200f);
			s_data = FocusSystem.DATA;
		}

		void OnEnable()
		{
			this.titleContent = new GUIContent("Focus Settings");
		}

		void OnGUI()
		{
			if (m_styleBox == null)
			{
				InitStyles();
			}

			if (s_data == null)
			{
				s_data = FocusSystem.DATA;
			}

			EditorGUI.BeginChangeCheck();

			EditorGUILayout.BeginVertical(m_styleBox);

			EditorGUILayout.LabelField("Settings", m_styleHeader);
			s_data.FocusDuration = EditorGUILayout.FloatField("Focus Duration", Mathf.Max(0f, s_data.FocusDuration));
			s_data.BoundsOffset = EditorGUILayout.FloatField("Bounds Offset", Mathf.Max(0f, s_data.BoundsOffset));

			EditorGUILayout.EndVertical();


			EditorGUILayout.BeginVertical(m_styleBox);
			s_data.e_debug = EditorGUILayout.BeginToggleGroup("Edit", s_data.e_debug);

			if (s_data.e_debug)
			{
				s_data.e_oldBoundsColor = EditorGUILayout.ColorField("Old Bounds", s_data.e_oldBoundsColor);
				s_data.e_newBoundsColor = EditorGUILayout.ColorField("New Bounds", s_data.e_newBoundsColor);
			}

			EditorGUILayout.EndToggleGroup();
			EditorGUILayout.EndVertical();

			if (EditorGUI.EndChangeCheck())
			{
				EditorUtility.SetDirty(s_data);
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
			if (s_data == null)
			{
				s_data = FocusSystem.DATA;
			}

			if (s_data.e_debug)
			{
				Vector3 oCenter = FocusSystem.OldFocusBounds.center;
				Vector3 oSize = FocusSystem.OldFocusBounds.size;

				Vector3 nCenter = FocusSystem.FocusedBounds.center;
				Vector3 nSize = FocusSystem.FocusedBounds.size;

				Color oldColor = Handles.color;

				Handles.color = s_data.e_oldBoundsColor;
				Handles.DrawWireCube(oCenter, oSize);

				Handles.color = s_data.e_newBoundsColor;
				Handles.DrawWireCube(nCenter, nSize);

				Handles.color = oldColor;
			}

		}
	}
}
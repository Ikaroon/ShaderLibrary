using System.IO;
using UnityEngine;

namespace Ikaroon.Focus
{
	public class FocusSystem : ScriptableObject
	{

		//DATA path
		private const string RAW_RES_PATH = "Resources/";
		private const string DATA_PATH = "FocusSystem/DATA";

		private readonly static string FULL_PATH = RAW_RES_PATH + DATA_PATH + ".asset";

		//Singleton
		private static FocusSystem s_cachedData;
		public static FocusSystem DATA
		{
			get
			{
				var fullPath = Path.Combine(GetPath(), FULL_PATH);
				var fullSystemPath = Path.GetDirectoryName(Path.GetFullPath(fullPath));
				if (!Directory.Exists(fullSystemPath))
					Directory.CreateDirectory(fullSystemPath);
				
				//No cached try to get it from the Resources folder
				if (s_cachedData == null)
				{
					s_cachedData = Resources.Load<FocusSystem>(DATA_PATH);
				}
				//Not cached then try to create it in the Resources Folder
				if (s_cachedData == null)
				{
#if UNITY_EDITOR
					s_cachedData = ScriptableObject.CreateInstance<FocusSystem>();
					UnityEditor.AssetDatabase.CreateAsset(s_cachedData, fullPath);
					UnityEditor.AssetDatabase.Refresh();
#endif
				}
				return s_cachedData;
			}
		}

		//Statics
		public static Bounds FocusedBounds { get { return s_focusedBounds; } }
		private static Bounds s_focusedBounds;
		public static Bounds OldFocusBounds { get { return s_oldFocusBounds; } }
		private static Bounds s_oldFocusBounds;

		//Fields
		public float FocusDuration { get { return m_focusDuration; } set { m_focusDuration = value; } }
		[SerializeField]
		private float m_focusDuration = 0.5f;
		public float BoundsOffset { get { return m_boundsOffset; } set { m_boundsOffset = value; } }
		[SerializeField]
		private float m_boundsOffset = 0.1f;

		//Selection
		private enum Dimension { X = 0, Y = 1, Z = 2 };

		//Editor
#if UNITY_EDITOR
		public bool e_debug = true;
		public Color e_oldBoundsColor = Color.red;
		public Color e_newBoundsColor = Color.green;
#endif

		public static void Focus(Bounds area)
		{
			s_oldFocusBounds = s_focusedBounds;
			s_focusedBounds = new Bounds(area.center, area.size + new Vector3(DATA.m_boundsOffset, DATA.m_boundsOffset, DATA.m_boundsOffset));
			
			Shader.SetGlobalVector("FOCUS_DATA", new Vector4(Time.timeSinceLevelLoad, DATA.m_focusDuration, 0f, 0f));
			SendBounds(s_oldFocusBounds, s_focusedBounds, Dimension.X);
			SendBounds(s_oldFocusBounds, s_focusedBounds, Dimension.Y);
			SendBounds(s_oldFocusBounds, s_focusedBounds, Dimension.Z);
		}

		public static void HardFocus(Bounds area)
		{
			s_focusedBounds = area;
			Focus(area);
		}

		private static void SendBounds(Bounds a, Bounds b, Dimension dim)
		{
			int dimension = (int)dim;
			Shader.SetGlobalVector("FOCUS_BOUNDS_" + dim, new Vector4(a.center[dimension] - a.extents[dimension], b.center[dimension] - b.extents[dimension], a.center[dimension] + a.extents[dimension], b.center[dimension] + b.extents[dimension]));
		}

		private static string GetPath([System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "")
		{
			var assetPath = Path.GetFullPath(Application.dataPath + "/");
			var scriptPath = Path.GetFullPath(sourceFilePath);
			scriptPath = Directory.GetParent(scriptPath).Parent.FullName;
			var path = scriptPath.Replace(assetPath, "");
			return Path.Combine("Assets/", path);
		}

	}
}
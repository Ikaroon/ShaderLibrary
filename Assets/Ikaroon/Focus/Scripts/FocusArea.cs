using UnityEngine;

namespace Ikaroon.Focus
{
	public class FocusArea : MonoBehaviour
	{

		//Singleton
		public static FocusArea s_main;

		public Bounds FocusBounds { get { return m_focusBounds; } set { m_focusBounds = value; } }
		[SerializeField]
		private Bounds m_focusBounds;

		//Editor Variables
		#if UNITY_EDITOR
		public bool e_edit = true;
		public Color e_targetBoundsColor = Color.blue;
		#endif

		private void Awake()
		{
			s_main = this;
		}

		public void Focus()
		{
			Bounds tempBounds = m_focusBounds;
			tempBounds.center += transform.position;
			FocusSystem.Focus(tempBounds);
		}

		public void HardFocus()
		{
			Bounds tempBounds = m_focusBounds;
			tempBounds.center += transform.position;
			FocusSystem.HardFocus(tempBounds);
		}

		#region Editor Debug

		#if UNITY_EDITOR
		private void OnDrawGizmosSelected()
		{
			if (e_edit)
			{
				Color oldColor = Gizmos.color;

				Gizmos.color = e_targetBoundsColor;
				Gizmos.DrawWireCube(transform.position + m_focusBounds.center, m_focusBounds.size);

				Gizmos.color = oldColor;
			}
		}
		#endif

		#endregion Editor Debug
	}
}
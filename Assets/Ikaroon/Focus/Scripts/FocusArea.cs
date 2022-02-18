using UnityEngine;

namespace Ikaroon.Focus
{
	public class FocusArea : MonoBehaviour
	{

		//Singleton
		public static FocusArea main;
		public Bounds focusBounds;

		//Editor Variables
		#if UNITY_EDITOR
		public bool e_edit = true;
		public Color e_targetBoundsColor = Color.blue;
		#endif

		private void Awake()
		{
			main = this;
		}

		public void Focus()
		{
			Bounds tempBounds = focusBounds;
			tempBounds.center += transform.position;
			FocusSystem.Focus(tempBounds);
		}

		public void HardFocus()
		{
			Bounds tempBounds = focusBounds;
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
				Gizmos.DrawWireCube(transform.position + focusBounds.center, focusBounds.size);

				Gizmos.color = oldColor;
			}
		}
		#endif

		#endregion Editor Debug
	}
}
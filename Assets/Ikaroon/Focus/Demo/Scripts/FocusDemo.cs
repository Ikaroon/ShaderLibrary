using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Ikaroon.Focus.Demo
{
	public class FocusDemo : MonoBehaviour
	{
		[SerializeField]
		FocusArea[] m_areas;

		[SerializeField]
		float m_interval;

		int m_lastIndex;

		void Start()
		{
			m_areas[m_lastIndex].HardFocus();
			var focusDuration = m_interval + FocusSystem.DATA.focusDuration;
			InvokeRepeating(nameof(FocusNext), focusDuration, focusDuration);
		}

		void FocusNext()
		{
			m_lastIndex = (m_lastIndex + 1) % m_areas.Length;
			var area = m_areas[m_lastIndex];
			area.Focus();
		}
	}
}

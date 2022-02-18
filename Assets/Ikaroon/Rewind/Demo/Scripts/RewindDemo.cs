using UnityEngine;

namespace Ikaroon.Rewind.Demo
{
	public class RewindDemo : MonoBehaviour
	{
		[SerializeField]
		AnimationCurve m_timeScaleOverTime;

		[SerializeField]
		float m_animationDuration;

		void Update()
		{
			var progress = Time.unscaledTime / m_animationDuration;
			Time.timeScale = m_timeScaleOverTime.Evaluate(progress);
		}
	}
}

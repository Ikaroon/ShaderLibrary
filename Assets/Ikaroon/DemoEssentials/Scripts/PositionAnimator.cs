using UnityEngine;

namespace Ikaroon.DemoEssentials
{
	public class PositionAnimator : MonoBehaviour
	{
		[SerializeField]
		AnimationCurve m_xOverTime;
		[SerializeField]
		AnimationCurve m_yOverTime;
		[SerializeField]
		AnimationCurve m_zOverTime;

		[SerializeField]
		float m_animationDuration;

		Vector3 m_origin;

		void Start()
		{
			m_origin = transform.position;
		}

		void Update()
		{
			var progress = Time.time / m_animationDuration;
			var x = m_xOverTime.Evaluate(progress);
			var y = m_yOverTime.Evaluate(progress);
			var z = m_zOverTime.Evaluate(progress);

			transform.position = m_origin + new Vector3(x, y, z);
		}
	}
}

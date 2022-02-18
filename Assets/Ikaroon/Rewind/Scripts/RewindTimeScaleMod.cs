using UnityEngine;

namespace Ikaroon.Rewind
{
	public class RewindTimeScaleMod : MonoBehaviour
	{
		[SerializeField]
		RewindEffect m_rewind;

		[SerializeField]
		private AnimationCurve m_lineSize = new AnimationCurve(new Keyframe(0f, 5f), new Keyframe(1f, 5f));

		[SerializeField]
		private AnimationCurve m_waveSizeX = new AnimationCurve(new Keyframe(1f, 0f), new Keyframe(15f, 10f));

		[SerializeField]
		private AnimationCurve m_waveSizeY = new AnimationCurve(new Keyframe(1f, 5f), new Keyframe(15f, 0.1f));

		[SerializeField]
		private AnimationCurve m_waveSpeed = new AnimationCurve(new Keyframe(1f, 0f), new Keyframe(15f, 10f));

		[SerializeField]
		private AnimationCurve m_waveStrength = new AnimationCurve(new Keyframe(1f, 0f), new Keyframe(15f, 10f));

		void Update()
		{
			m_rewind.LineSize = m_lineSize.Evaluate(Time.timeScale);

			m_rewind.WaveSize = new Vector2(m_waveSizeX.Evaluate(Time.timeScale), m_waveSizeY.Evaluate(Time.timeScale));

			m_rewind.WaveSpeed = m_waveSpeed.Evaluate(Time.timeScale);
			m_rewind.WaveStrength = m_waveStrength.Evaluate(Time.timeScale);
		}
	}
}

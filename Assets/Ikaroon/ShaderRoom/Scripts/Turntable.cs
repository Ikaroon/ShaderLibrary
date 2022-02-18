using UnityEngine;

namespace Ikaroon.ShaderRoom
{
	public class Turntable : MonoBehaviour
	{
		[SerializeField]
		Vector3 m_angles;

		void Update()
		{
			transform.Rotate(m_angles * Time.deltaTime, Space.World);
		}
	}
}

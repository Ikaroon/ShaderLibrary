Shader "Hidden/Ikaroon/MeshToObjectNormalTexture"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 normal : NORMAL;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = float4(v.uv.xy * 2 - 1, 1, 1);
				#if UNITY_UV_STARTS_AT_TOP
				o.vertex.y *= -1;
				#endif
				o.normal = v.normal;
				return o;
			}

			float4 frag (v2f i) : SV_Target
			{
				return float4(i.normal.xyz * 0.5 + 0.5, 1);
			}
			ENDCG
		}
	}
}

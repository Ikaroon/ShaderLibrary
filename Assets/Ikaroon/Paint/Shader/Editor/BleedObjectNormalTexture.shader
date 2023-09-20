Shader "Hidden/Ikaroon/BleedObjectNormalTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			void SampleAt(v2f i, float2 offset, inout float3 normal, inout int steps)
			{
				float3 o = tex2D(_MainTex, i.uv + offset).rgb;
				float3 n = o * 2 - 1;
				float strength = length(o);

				if (strength < 0.01)
					return;

				steps += 1;
				normal += n;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 localO = tex2D(_MainTex, i.uv).rgb;
				float localStrength = length(localO);

				if (localStrength > 0.01)
					return float4(localO.rgb, 1);

				float3 normal = float3(0,0,0);
				int steps = 0;

				float2 p = _MainTex_TexelSize.xy;
				SampleAt(i, float2(-p.x, -p.y), normal, steps);
				SampleAt(i, float2(-p.x, 0), normal, steps);
				SampleAt(i, float2(-p.x, p.y), normal, steps);
				SampleAt(i, float2(0, p.y), normal, steps);
				SampleAt(i, float2(p.x, p.y), normal, steps);
				SampleAt(i, float2(p.x, 0), normal, steps);
				SampleAt(i, float2(p.x, -p.y), normal, steps);
				SampleAt(i, float2(0, -p.y), normal, steps);

				if (steps == 0)
					return float4(localO.rgb, 1);

				normal /= steps;

				return float4(normal * 0.5 + 0.5, 1);
			}
			ENDCG
		}
	}
}

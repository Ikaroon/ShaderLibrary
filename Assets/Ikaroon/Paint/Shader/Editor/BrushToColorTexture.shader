Shader "Hidden/Ikaroon/BrushToColorTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BrushTex ("Brush", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "gray" {}
		_BrushBounds ("Brush Bounds", Vector) = (0,0,1,1)
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			sampler2D _MainTex;

			sampler2D _BrushTex;
			float4 _BrushBounds;
			float4x4 _BrushRotation;

			sampler2D _NoiseTex;
			float _NoiseStrength;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 center : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			float InverseLerp(float a, float b, float x)
			{
				return (x - a) * (1 / (b - a));
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				o.center = float2(
					lerp(_BrushBounds.x, _BrushBounds.z, 0.5),
					lerp(_BrushBounds.y, _BrushBounds.w, 0.5)
					);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float2 rUV = mul(i.uv - i.center, (float2x2)_BrushRotation) + i.center;

				float2 uv2 = float2(
					InverseLerp(_BrushBounds.x, _BrushBounds.z, rUV.x),
					InverseLerp(_BrushBounds.y, _BrushBounds.w, rUV.y)
					);

				float3 col = tex2D(_MainTex, i.uv);
				float3 centerOffset = tex2D(_NoiseTex, i.center).rgb;

				float3 finalColor = float3(1,1,1) - centerOffset * _NoiseStrength;
				float brush = tex2D(_BrushTex, uv2).r;

				float2 brushStrength = saturate(abs(1 - (uv2 * 2 - 1)));
				brush = brush * brushStrength.x * brushStrength.y;

				return float4(lerp(col, finalColor, brush), 1);
			}
			ENDCG
		}
	}
}

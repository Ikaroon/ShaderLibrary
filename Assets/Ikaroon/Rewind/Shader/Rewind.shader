Shader "Hidden/Ikaroon/Rewind"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LineSize("Scanline Size", Float) = 1
		_WaveSizeX ("Wave Size X", Float) = 10
		_WaveSizeY ("Wave Size Y", Float) = 10
		_WaveSpeed ("Wave Speed", Float) = 1
		_WaveApply("Wave Apply", Float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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
			
			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			float _LineSize;

			float _WaveSizeX;
			float _WaveSizeY;
			float _WaveSpeed;
			float _WaveApply;

			fixed4 frag (v2f i) : SV_Target
			{
				float xOffset = sin((i.uv.y * _MainTex_TexelSize.w + _Time.y * _WaveSpeed) * (1 / max(_WaveSizeY * 100, 1))) * (_WaveSizeX * 0.1);
				xOffset *= _WaveApply;

				fixed4 col = tex2D(_MainTex, float2(i.uv.x + xOffset, i.uv.y));
				
				float l = saturate(round(((i.uv.y * _MainTex_TexelSize.w) % _LineSize) / _LineSize));
				col.rgb *= lerp(0.75, 1, l);

				return col;
			}
			ENDCG
		}
	}
}

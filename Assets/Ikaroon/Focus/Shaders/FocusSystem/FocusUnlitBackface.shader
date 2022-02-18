Shader "Ikaroon/Focus/Unlit Backface"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Albedo("Albedo (RGB)", 2D) = "white" {}

		_FocusOutsideMin("Min Visiblity on lost Focus", Range(0,1)) = 0 //TODO: change to shader_feature - only used by a couple objects

																	//Extra Data
		_FocusOffset("Focus Offset", Vector) = (0,0,0,0)
		_DepthOffset("Z-Write Offset", Int) = 0
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Offset 0,[_DepthOffset]

		Cull Front

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#include "../Libs/FocusSystem.cginc"
			#include "../Libs/OrderedDither.cginc"

			fixed4 _Color;
			sampler2D _Albedo;
			float4 _Albedo_ST;
			sampler2D _NormalMap;
			sampler2D _OSM;

			float _OcculusionMultiplier;
			float _RoughnessMultiplier;
			float _RoughnessApply;
			float _MetalnessMultiplier;

			sampler2D _EmissionMap;
			float4 _EmissionColor;
			float _Emission;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
			};

			float3 _FocusOffset;
			float _FocusOutsideMin;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Albedo);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.screenPos = ComputeScreenPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//Fading of outer Objects:
				bool insideOld = InsideFocusArea(i.worldPos, _FocusOffset, FOCUS_OLD_BOUND);
				bool insideNew = InsideFocusArea(i.worldPos, _FocusOffset, FOCUS_NEW_BOUNDS);

				//Clip all not visible Objects
				if (insideOld == false && insideNew == false) {
					DitherVisiblity(i.screenPos, _FocusOutsideMin);
				}

				//Calulcate the fading process
				float fade = (_Time.y - FOCUS_DATA.x) / FOCUS_DATA.y;

				//Fade Out all lost Objects
				if (insideOld == true && insideNew == false) {
					DitherVisiblity(i.screenPos, max(_FocusOutsideMin, 1 - fade));
				}

				//Fade in all invisible focused Objects
				if (insideOld == false && insideNew == true) {
					DitherVisiblity(i.screenPos, max(_FocusOutsideMin, fade));
				}

				//Color Values
				fixed4 c = tex2D(_Albedo, i.uv) * _Color;

				clip(c.a - 0.5);

				return c;

			}
			ENDCG
		}
	}
}

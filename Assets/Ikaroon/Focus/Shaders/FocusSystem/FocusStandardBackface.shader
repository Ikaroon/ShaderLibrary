Shader "Ikaroon/Focus/Standard Backface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_Emission("Emission", Float) = 1.0
		_EmissionColor("Emission Color", Color) = (1,1,1,1)
		
		_FocusOutsideMin("Min Visiblity on lost Focus", Range(0,1)) = 0 //TODO: change to shader_feature - only used by a couple objects

		//Extra Data
		_FocusOffset ("Focus Offset", Vector) = (0,0,0,0)
		_DepthOffset("Z-Write Offset", Int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Offset 0,[_DepthOffset]
		Cull Front
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert
		#pragma target 3.0

		#include "../Libs/FocusSystem.cginc"
		#include "../Libs/OrderedDither.cginc"

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
			float4 screenPos;
		};

		void vert(inout appdata_full v) {
			v.normal.xyz = -v.normal.xyz;
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float4 _EmissionColor;
		float _Emission;

		float3 _FocusOffset;
		float _FocusOutsideMin;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			//Fading of outer Objects:
			bool insideOld = InsideFocusArea(IN.worldPos, _FocusOffset, FOCUS_OLD_BOUND);
			bool insideNew = InsideFocusArea(IN.worldPos, _FocusOffset, FOCUS_NEW_BOUNDS);

			//Clip all not visible Objects
			if (insideOld == false && insideNew == false) {
				DitherVisiblity(IN.screenPos, _FocusOutsideMin);
			}

			//Calulcate the fading process
			float fade = (_Time.y - FOCUS_DATA.x) / FOCUS_DATA.y;

			//Fade Out all lost Objects
			if (insideOld == true && insideNew == false) {
				DitherVisiblity(IN.screenPos, max(_FocusOutsideMin, 1 - fade));
			}

			//Fade in all invisible focused Objects
			if (insideOld == false && insideNew == true) {
				DitherVisiblity(IN.screenPos, max(_FocusOutsideMin, fade));
			}

			//Color Values
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;

			clip(c.a - 0.5);

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission = c.rgb * _EmissionColor.rgb * _Emission;
		}
		ENDCG
	}
	FallBack "Diffuse"
	CustomEditor "FocusStandardUI"
}

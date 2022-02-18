Shader "Ikaroon/Focus/Standard" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Albedo ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
		_OSM("ORM", 2D) = "gray" {}

		_OcculusionMultiplier("Occulusion Multiplier", Range(0,1)) = 1
		_RoughnessMultiplier("Roughness Multiplier", Range(0,1)) = 1
		_RoughnessApply("Roughness Strength", Range(0,1)) = 0
		_MetalnessMultiplier("Metalness Multiplier", Range(0,1)) = 1

		_EmissionMap("Emission Map", 2D) = "white" {}

		_EmissionColor("Emission Color", Color) = (0,0,0,0)
		_Emission("Emission", Float) = 0.0
		
		_FocusOutsideMin("Min Visiblity on lost Focus", Range(0,1)) = 0 //TODO: change to shader_feature - only used by a couple objects
		_FocusInside("Visiblity inside Focus", Range(0,1)) = 1 //TODO: change to shader_feature - only used by a couple objects

		//Extra Data
		_FocusOffset ("Focus Offset", Vector) = (0,0,0,0)
		_DepthOffset("Z-Write Offset", Int) = 0
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		Offset 0,[_DepthOffset]

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		#include "../Libs/FocusSystem.cginc"
		#include "../Libs/OrderedDither.cginc"

		fixed4 _Color;
		sampler2D _Albedo;
		sampler2D _NormalMap;
		sampler2D _OSM;

		float _OcculusionMultiplier;
		float _RoughnessMultiplier;
		float _RoughnessApply;
		float _MetalnessMultiplier;

		sampler2D _EmissionMap;
		float4 _EmissionColor;
		float _Emission;

		struct Input {
			float2 uv_Albedo;
			float2 uv_NormalMap;

			float3 worldPos;
			float4 screenPos;
		};

		float3 _FocusOffset;
		float _FocusOutsideMin;
		float _FocusInside;

		void surf(Input IN, inout SurfaceOutputStandard o) {
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
				DitherVisiblity(IN.screenPos, min(max(_FocusOutsideMin, 1 - fade), _FocusInside));
			}

			//Fade in all invisible focused Objects
			if (insideOld == false && insideNew == true) {
				DitherVisiblity(IN.screenPos, min(max(_FocusOutsideMin, fade), _FocusInside));
			}

			//Apply Visiblity to all visible Objects
			if (insideOld == true && insideNew == true) {
				DitherVisiblity(IN.screenPos, _FocusInside);
			}

			//Color Values
			fixed4 c = tex2D(_Albedo, IN.uv_Albedo) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;

			clip(c.a - 0.5);

			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));

			fixed4 osm = tex2D(_OSM, IN.uv_Albedo);
			o.Occlusion = osm.r * _OcculusionMultiplier;
			o.Smoothness = (1 - osm.g * _RoughnessMultiplier) * _RoughnessApply;
			o.Metallic = osm.b * _MetalnessMultiplier;

			o.Emission = tex2D(_EmissionMap, IN.uv_Albedo) * _EmissionColor.rgb * _Emission;
		}
		ENDCG

		// ------------------------------------------------------------------
		// Extracts information for lightmapping, GI (emission, albedo, ...)
		// This pass is not used during regular rendering.
		Pass
		{
			Name "META"
			Tags{ "LightMode" = "Meta" }

			Cull Off

			CGPROGRAM
			#pragma vertex vert_meta
			#pragma fragment frag_meta

			#pragma shader_feature _EMISSION
			#pragma shader_feature _METALLICGLOSSMAP

			#include "UnityStandardMeta.cginc"
			ENDCG
		}
	}
	FallBack "Diffuse"
	CustomEditor "FocusStandardUI"
}

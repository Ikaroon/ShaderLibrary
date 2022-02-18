Shader "Ikaroon/Standard Glitter"
{
	Properties
	{
		_NoiseScale ("Noise Scale", Float) = 1.0
		_AmplifierScale ("Amplifier Scale", Float) = 1.0
		_ScaleOnDistance("Scale On Distance", Float) = 0.005

		_Depth("Depth", Range(0,1)) = 1.0
		_Influence("Influence", Range(0,1)) = 1.0
		_SpecularInfluence("Specular Influence", Range(0,1)) = 1.0
		_Start("Start", Range(0,1)) = 0.5
		_End("End", Range(0,1)) = 1.0

		_Brightness("Brightness", Float) = 15

		_GlitterColor("Glitter Color", Color) = (1,1,1,1)

		_MainTex("Texture", 2D) = "black" {}
		_Normal("Normal", 2D) = "bump" {}
		_Metallic("Metallic", 2D) = "black" {}
		_Roughness("Roughness", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "Lib/glitter.cginc"

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_Normal;
			float2 uv_Metallic;
			float2 uv_Roughness;

			float3 worldPos;
			float3 worldNormal; INTERNAL_DATA
		};

		sampler2D _MainTex;
		sampler2D _Normal;
		sampler2D _Metallic;
		sampler2D _Roughness;

		float _NoiseScale;
		float _AmplifierScale;
		float _ScaleOnDistance;

		float _Depth;
		float _Influence;
		float _SpecularInfluence;
		float _Start;
		float _End;
		float _Brightness;

		float3 _GlitterColor;

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));

			pixelData data;
			data.position = IN.worldPos;
			data.normal = WorldNormalVector(IN, o.Normal);
			data.viewDirection = data.position - _WorldSpaceCameraPos;
			data.viewDistance = length(data.viewDirection);
			data.viewDirection = data.viewDirection / data.viewDistance;
			data.lightDirection = normalize(_WorldSpaceLightPos0.rgb);

			float3 glitter = getGlitter(
				data,
				_NoiseScale,
				_AmplifierScale,
				_ScaleOnDistance,
				_Depth,
				_Influence,
				_SpecularInfluence,
				_Start,
				_End,
				_Brightness,
				_GlitterColor);

			float3 col = tex2D(_MainTex, IN.uv_MainTex).rgb;

			o.Albedo = col.rgb;
			o.Emission = glitter.rgb * col;
			o.Metallic = tex2D(_Metallic, IN.uv_Metallic).r;
			o.Smoothness = 1 - tex2D(_Roughness, IN.uv_Roughness).r;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

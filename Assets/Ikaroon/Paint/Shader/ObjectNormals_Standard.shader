Shader "Custom/ObjectNormals_Standard"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_PaintTex ("Paint (RGB)", 2D) = "white" {}
		_ObjectNormals ("Object Normals", 2D) = "black" {}
		_BackFacingDecimator ("Back Facing Decimator", Range(0, 1)) = 0.2
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "UnityStandardUtils.cginc"

		sampler2D _MainTex;
		sampler2D _PaintTex;
		sampler2D _ObjectNormals;
		half _BackFacingDecimator;

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_PaintTex;
			float2 uv_ObjectNormals;
			half3 worldNormal;
			float3 worldPos;
			INTERNAL_DATA
		};

		float InverseLerp(float a, float b, float x)
		{
			return (x - a) * (1 / (b - a));
		}

		half3 WorldToTangentNormalVector(Input IN, half3 normal) {
			half3 t2w0 = WorldNormalVector(IN, half3(1,0,0));
			half3 t2w1 = WorldNormalVector(IN, half3(0,1,0));
			half3 t2w2 = WorldNormalVector(IN, half3(0,0,1));
			float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
			return normalize(mul(t2w, normal));
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			half3 sourceNormal = IN.worldNormal = WorldNormalVector(IN, half3(0,0,1));
			half3 viewDir = normalize(IN.worldPos - _WorldSpaceCameraPos.xyz);

			// Albedo comes from a texture tinted by color
			fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			color *= tex2D(_PaintTex, IN.uv_PaintTex);
			o.Albedo = color.rgb;
			o.Alpha = color.a;

			half4 objectNormal = tex2D(_ObjectNormals, IN.uv_ObjectNormals) * 2 - 1;
			half3 facetNormal = mul(unity_ObjectToWorld, objectNormal.xyz);
			half facetStrength = saturate(InverseLerp(0, -_BackFacingDecimator, dot(viewDir, facetNormal)));
			half3 worldNormal = lerp(sourceNormal, facetNormal, facetStrength);
			o.Normal = WorldToTangentNormalVector(IN, worldNormal);

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

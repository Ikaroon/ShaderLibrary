Shader "Custom/ObjectNormals_Standard"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_PaintTex ("Paint (RGB)", 2D) = "white" {}
		_ObjectNormals ("Object Normals", 2D) = "black" {}
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

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_PaintTex;
			float2 uv_ObjectNormals;
			float3 worldNormal;
			float3 worldPos;
			INTERNAL_DATA
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float InverseLerp(float a, float b, float x)
		{
			return (x - a) * (1 / (b - a));
		}

		float3 WorldToTangentNormalVector(Input IN, float3 normal) {
			float3 t2w0 = WorldNormalVector(IN, float3(1,0,0));
			float3 t2w1 = WorldNormalVector(IN, float3(0,1,0));
			float3 t2w2 = WorldNormalVector(IN, float3(0,0,1));
			float3x3 t2w = float3x3(t2w0, t2w1, t2w2);
			return normalize(mul(t2w, normal));
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float3 sourceNormal = IN.worldNormal = WorldNormalVector(IN, float3(0,0,1));
			float3 viewDir = normalize(IN.worldPos - _WorldSpaceCameraPos.xyz);

			// Albedo comes from a texture tinted by color
			fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			color *= tex2D(_PaintTex, IN.uv_PaintTex);
			o.Albedo = color.rgb;
			o.Alpha = color.a;

			fixed4 objectNormal = tex2D(_ObjectNormals, IN.uv_ObjectNormals) * 2 - 1;
			float3 worldNormal = mul(unity_ObjectToWorld, objectNormal.xyz);
			float facetStrength = saturate(InverseLerp(0, -0.2, dot(viewDir, worldNormal)));
			worldNormal = lerp(sourceNormal, worldNormal, facetStrength);
			o.Normal = WorldToTangentNormalVector(IN, worldNormal);

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

Shader "Ikaroon/Glitter/Standard Morph Demo"
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

		_Tess("Tessellation", Range(1,32)) = 4
		_MorphAmount("Morph Amount", Float) = 2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows vertex:vert tessellate:tessDistance

		#pragma target 4.6

		#include "Lib/glitter.cginc"
		#include "Lib/snoise.cginc"
		#include "Tessellation.cginc"

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

		float _MorphAmount;

		float _Tess;

		float4 tessDistance(appdata_full v0, appdata_full v1, appdata_full v2) {
			float minDist = 10.0;
			float maxDist = 25.0;
			return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
		}

		void vert(inout appdata_full v) {
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
			float3 worldNormal = mul(unity_ObjectToWorld, v.normal);
			float noise = snoise((worldPos + float3(0, -_Time.y, 0)) * 0.5);

			worldPos.xyz += worldNormal * (noise * 0.5 + 0.5) * _MorphAmount;
			v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			o.Normal = UnpackNormal(tex2D(_Normal, IN.uv_Normal));
			
			float3 worldScale = float3(
				length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x)), // scale x axis
				length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y)), // scale y axis
				length(float3(unity_ObjectToWorld[0].z, unity_ObjectToWorld[1].z, unity_ObjectToWorld[2].z))  // scale z axis
				);

			float3 localPosition = mul(unity_WorldToObject, float4(IN.worldPos, 1)).xyz;
			localPosition = localPosition * worldScale;

			pixelData data;
			data.position = localPosition;
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

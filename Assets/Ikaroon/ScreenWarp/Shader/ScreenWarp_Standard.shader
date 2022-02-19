Shader "Ikaroon/Screen Warp/Standard"
{
	Properties
	{
		_MainTex ("Main", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1,1,1,1)
		_MainOffset("Main Offset", Float) = 2.0

		_Emission("Emission", 2D) = "black" {}
		_EmissionColor("Emission Color", Color) = (1,1,1,1)
		_EmissionOffset("Emission Offset", Float) = 1.0

		_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_FresnelPower("Fresnel Power", Float) = 1.0
		_FresnelOffset("Fresnel Offset", Float) = 0.5

		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows

		#pragma target 3.0

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _MainColor;
		float _MainOffset;

		sampler2D _Emission;
		float4 _Emission_ST;
		float4 _EmissionColor;
		float _EmissionOffset;

		float4 _FresnelColor;
		float _FresnelPower;
		float _FresnelOffset;

		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;

		float invLerp(float a, float b, float x)
		{
			return (x - a) * (1 / (b - a));
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float3 worldPos = IN.worldPos - IN.worldNormal * _MainOffset;
			float4 screenPos = ComputeScreenPos(mul(UNITY_MATRIX_VP, float4(worldPos.xyz, 1)));
			screenPos = screenPos / screenPos.w;

			float2 ratio = float2(_ScreenParams.x / _ScreenParams.y, 1);

			float4 col = tex2D(_MainTex, screenPos.xy * ratio * _MainTex_ST.xy) * _MainColor;

			worldPos = IN.worldPos - IN.worldNormal * _EmissionOffset;
			screenPos = ComputeScreenPos(mul(UNITY_MATRIX_VP, float4(worldPos.xyz, 1)));
			screenPos = screenPos / screenPos.w;
			float4 emission = tex2D(_Emission, screenPos.xy * ratio * _Emission_ST.xy) * _EmissionColor;

			float3 viewDir = IN.worldPos - _WorldSpaceCameraPos;
			float fresnel = abs(-dot(IN.worldNormal, viewDir));
			fresnel = 1 - saturate(invLerp(0, _FresnelOffset, fresnel));
			fresnel = pow(fresnel, _FresnelPower);

			col += _FresnelColor * fresnel;

			o.Albedo = col.rgb;
			o.Emission = emission;


			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = col.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}

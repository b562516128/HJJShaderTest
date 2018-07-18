// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Mine/HJJ/glassRefraction"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_NormalMap ("Normal Texture", 2D) = "white" {}
		_CubeMap ("CubeMap", Cube) = "_skybox" {}
		_Distortion("Distortion", Range(0, 100)) = 10
		_RefractAmount("Refract Amount", Range(0.00, 1.0)) = 1.0
		_BumpScale("BumpScale", Range(1, 10)) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent" }
		LOD 100

		GrabPass{"_RefractionTex"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed3 normal : NORMAL;
				fixed4 tangent : TANGENT;

			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 srcPos : TEXCOORD4;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			samplerCUBE _CubeMap;
			float _Distortion;
			float _RefractAmount;
			float _BumpScale;
		
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.srcPos = ComputeGrabScreenPos(o.vertex);

				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _NormalMap);
				UNITY_TRANSFER_FOG(o,o.vertex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			
				fixed3 col = tex2D(_MainTex, i.uv.xy).rgb;

				// sample the texture
				fixed3 bump = UnpackNormal(tex2D(_NormalMap, i.uv.zw));
				bump = normalize(fixed3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				bump.xy = bump.xy * _BumpScale;
				bump.z = sqrt(1- saturate(dot(bump.xy, bump.xy.xy)));
				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.srcPos.xy = i.srcPos.xy + offset;

				fixed3 refraCol = tex2D(_RefractionTex, i.srcPos.xy/i.srcPos.w).rgb;

				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed3 diffuse = texCUBE(_CubeMap, reflDir) * (1 - _RefractAmount) * col + refraCol * _RefractAmount;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				return float4(diffuse, 1);
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}

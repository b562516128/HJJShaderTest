Shader "Mine/util/hjjTest"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 localPosition : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				float3 normal:TEXCOORD2;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				float x = v.vertex.x;
				//v.vertex.x = x > 0 ? x - 0.2 : x + sin(_Time.y);

				o.localPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyzw;
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 lpos = i.worldPosition;
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(lpos.xyz));
				
				lpos.xyz = fixed3(0,1, 0) * pow((1 - dot(worldViewDir, i.normal)), 3) * 5;

				return lpos ;// fixed4(0, 1, 0, 1);
			}
			ENDCG
		}
	}
}

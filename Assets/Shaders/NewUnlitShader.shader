﻿Shader "BoatAttack/PackedPBR"
{
	Properties
	{
				[NoScaleOffset] _MainTex("Albedo_Roughness", 2D) = "white" {}
				[NoScaleOffset] Texture_DE8BF47E("Normal_AO", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)

	}
	SubShader
	{
		Tags{ "RenderPipeline" = "LightweightPipeline"}
		Tags
		{
			"RenderType"="Opaque"
			"Queue"="Geometry"
		}
		
		Pass
		{
			Tags{"LightMode" = "LightweightForward"}
			
					Blend One Zero
		
					Cull Back
		
					ZTest LEqual
		
					ZWrite On
		
		
			HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
			#pragma target 3.0
		
			// -------------------------------------
			// Lightweight Pipeline keywords
			#pragma multi_compile _ _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _VERTEX_LIGHTS
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ FOG_LINEAR FOG_EXP2
		
			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
		
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
		
		    #pragma vertex vert
			#pragma fragment frag
		
						#define _NORMALMAP 1
		
		
			#include "LWRP/ShaderLibrary/Core.hlsl"
			#include "LWRP/ShaderLibrary/Lighting.hlsl"
			#include "CoreRP/ShaderLibrary/Color.hlsl"
			#include "CoreRP/ShaderLibrary/UnityInstancing.hlsl"
			#include "ShaderGraphLibrary/Functions.hlsl"
		
								TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
							TEXTURE2D(Texture_DE8BF47E); SAMPLER(samplerTexture_DE8BF47E);
					
							struct SurfaceInputs{
								half4 uv0;
							};
					
					
					        void Unity_Subtract_float4(float4 A, float4 B, out float4 Out)
					        {
					            Out = A - B;
					        }
					
					        void Unity_Multiply_float (float4 A, float4 B, out float4 Out)
					        {
					            Out = A * B;
					        }
					
							struct GraphVertexInput
							{
								float4 vertex : POSITION;
								float3 normal : NORMAL;
								float4 tangent : TANGENT;
								float4 texcoord0 : TEXCOORD0;
								float4 texcoord1 : TEXCOORD1;
								UNITY_VERTEX_INPUT_INSTANCE_ID
							};
					
							struct SurfaceDescription{
								float3 Albedo;
								float3 Normal;
								float3 Emission;
								float Metallic;
								float Smoothness;
								float Occlusion;
								float Alpha;
								float AlphaClipThreshold;
							};
					
							GraphVertexInput PopulateVertexData(GraphVertexInput v){
								return v;
							}
					
							SurfaceDescription PopulateSurfaceData(SurfaceInputs IN) {
								SurfaceDescription surface = (SurfaceDescription)0;
								float4 _SampleTexture2D_903562CE_RGBA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv0.xy);
								float _SampleTexture2D_903562CE_R = _SampleTexture2D_903562CE_RGBA.r;
								float _SampleTexture2D_903562CE_G = _SampleTexture2D_903562CE_RGBA.g;
								float _SampleTexture2D_903562CE_B = _SampleTexture2D_903562CE_RGBA.b;
								float _SampleTexture2D_903562CE_A = _SampleTexture2D_903562CE_RGBA.a;
								float4 _SampleTexture2D_D53F4AE6_RGBA = SAMPLE_TEXTURE2D(Texture_DE8BF47E, samplerTexture_DE8BF47E, IN.uv0.xy);
								float _SampleTexture2D_D53F4AE6_R = _SampleTexture2D_D53F4AE6_RGBA.r;
								float _SampleTexture2D_D53F4AE6_G = _SampleTexture2D_D53F4AE6_RGBA.g;
								float _SampleTexture2D_D53F4AE6_B = _SampleTexture2D_D53F4AE6_RGBA.b;
								float _SampleTexture2D_D53F4AE6_A = _SampleTexture2D_D53F4AE6_RGBA.a;
								float4 _Subtract_2BA4AC9D_Out;
								Unity_Subtract_float4(_SampleTexture2D_D53F4AE6_RGBA, float4(0.5, 0.5, 0.5, 0.5), _Subtract_2BA4AC9D_Out);
								float4 _Multiply_2407F12D_Out;
								Unity_Multiply_float(_Subtract_2BA4AC9D_Out, float4(2, 2, 2, 0), _Multiply_2407F12D_Out);
								
								surface.Albedo = (_SampleTexture2D_903562CE_RGBA.xyz);
								surface.Normal = (_Multiply_2407F12D_Out.xyz);
								surface.Emission = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
								surface.Metallic = 0;
								surface.Smoothness = _SampleTexture2D_903562CE_A;
								surface.Occlusion = _SampleTexture2D_D53F4AE6_A;
								surface.Alpha = 1;
								surface.AlphaClipThreshold = 0;
								return surface;
							}
					
		
		
			struct GraphVertexOutput
		    {
		        float4 clipPos                : SV_POSITION;
		        float4 lightmapUVOrVertexSH   : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1; // x: fogFactor, yzw: vertex light
		    	float4 shadowCoord            : TEXCOORD2;
		        			float3 WorldSpaceNormal : TEXCOORD3;
					float3 WorldSpaceTangent : TEXCOORD4;
					float3 WorldSpaceBiTangent : TEXCOORD5;
					float3 WorldSpaceViewDirection : TEXCOORD6;
					float3 WorldSpacePosition : TEXCOORD7;
					half4 uv0 : TEXCOORD8;
					half4 uv1 : TEXCOORD9;
		
		        UNITY_VERTEX_INPUT_INSTANCE_ID
		    };
		
		    GraphVertexOutput vert (GraphVertexInput v)
			{
			    v = PopulateVertexData(v);
		
		        GraphVertexOutput o = (GraphVertexOutput)0;
		
		        UNITY_SETUP_INSTANCE_ID(v);
		    	UNITY_TRANSFER_INSTANCE_ID(v, o);
		
		        			o.WorldSpaceNormal = mul(v.normal,(float3x3)UNITY_MATRIX_I_M);
					o.WorldSpaceTangent = mul((float3x3)UNITY_MATRIX_M,v.tangent);
					o.WorldSpaceBiTangent = normalize(cross(o.WorldSpaceNormal, o.WorldSpaceTangent.xyz) * v.tangent.w);
					o.WorldSpaceViewDirection = SafeNormalize(_WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), float4(v.vertex.xyz, 1.0)).xyz);
					o.WorldSpacePosition = mul(UNITY_MATRIX_M,v.vertex);
					o.uv0 = v.texcoord0;
					o.uv1 = v.texcoord1;
		
		
				float3 lwWNormal = TransformObjectToWorldNormal(v.normal);
				float3 lwWorldPos = TransformObjectToWorld(v.vertex.xyz);
				float4 clipPos = TransformWorldToHClip(lwWorldPos);
		
		 		// We either sample GI from lightmap or SH. lightmap UV and vertex SH coefficients
			    // are packed in lightmapUVOrVertexSH to save interpolator.
			    // The following funcions initialize
			    OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH);
			    OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH);
		
			    half3 vertexLight = VertexLighting(lwWorldPos, lwWNormal);
			    half fogFactor = ComputeFogFactor(clipPos.z);
			    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
			    o.clipPos = clipPos;
		
			    o.shadowCoord = ComputeShadowCoord(o.clipPos);
				return o;
			}
		
			half4 frag (GraphVertexOutput IN) : SV_Target
		    {
		    	UNITY_SETUP_INSTANCE_ID(IN);
		
		    				float3 WorldSpaceNormal = normalize(IN.WorldSpaceNormal);
					float3 WorldSpaceTangent = IN.WorldSpaceTangent;
					float3 WorldSpaceBiTangent = IN.WorldSpaceBiTangent;
					float3 WorldSpaceViewDirection = normalize(IN.WorldSpaceViewDirection);
					float3 WorldSpacePosition = IN.WorldSpacePosition;
					float4 uv0 = IN.uv0;
					float4 uv1 = IN.uv1;
		
		
		        SurfaceInputs surfaceInput = (SurfaceInputs)0;
		        			surfaceInput.uv0 = uv0;
		
		
		        SurfaceDescription surf = PopulateSurfaceData(surfaceInput);
		
				float3 Albedo = float3(0.5, 0.5, 0.5);
				float3 Specular = float3(0, 0, 0);
				float Metallic = 1;
				float3 Normal = float3(0, 0, 1);
				float3 Emission = 0;
				float Smoothness = 0.5;
				float Occlusion = 1;
				float Alpha = 1;
				float AlphaClipThreshold = 0;
		
		        			Albedo = surf.Albedo;
					Normal = surf.Normal;
					Emission = surf.Emission;
					Metallic = surf.Metallic;
					Smoothness = surf.Smoothness;
					Occlusion = surf.Occlusion;
					Alpha = surf.Alpha;
					AlphaClipThreshold = surf.AlphaClipThreshold;
		
		
				InputData inputData;
				inputData.positionWS = WorldSpacePosition;
		
		#ifdef _NORMALMAP
			    inputData.normalWS = TangentToWorldNormal(Normal, WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
		#else
			    inputData.normalWS = normalize(WorldSpaceNormal);
		#endif
		
		#ifdef SHADER_API_MOBILE
			    // viewDirection should be normalized here, but we avoid doing it as it's close enough and we save some ALU.
			    inputData.viewDirectionWS = WorldSpaceViewDirection;
		#else
			    inputData.viewDirectionWS = normalize(WorldSpaceViewDirection);
		#endif
		
			    inputData.shadowCoord = IN.shadowCoord;
		
			    inputData.fogCoord = IN.fogFactorAndVertexLight.x;
			    inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
			    inputData.bakedGI = SampleGI(IN.lightmapUVOrVertexSH, inputData.normalWS);
		
				half4 color = LightweightFragmentPBR(
					inputData, 
					Albedo, 
					Metallic, 
					Specular, 
					Smoothness, 
					Occlusion, 
					Emission, 
					Alpha);
		
				// Computes fog factor per-vertex
		    	ApplyFog(color.rgb, IN.fogFactorAndVertexLight.x);
		
		#if _AlphaClip
				clip(Alpha - AlphaClipThreshold);
		#endif
				return color;
		    }
		
			ENDHLSL
		}
		
		Pass
		{
		    Tags{"LightMode" = "ShadowCaster"}
		
		    ZWrite On
		    ZTest LEqual
		    Cull Back
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		    #pragma target 2.0
		    
		    //--------------------------------------
		    // GPU Instancing
		    #pragma multi_compile_instancing
		
		    #pragma vertex ShadowPassVertex
		    #pragma fragment ShadowPassFragment
		
		    #include "LWRP/ShaderLibrary/LightweightPassShadow.hlsl"
		    ENDHLSL
		}
		
		Pass
		{
		    Tags{"LightMode" = "DepthOnly"}
		
		    ZWrite On
		    ColorMask 0
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		    #pragma target 2.0
		    
		    //--------------------------------------
		    // GPU Instancing
		    #pragma multi_compile_instancing
		
		    #pragma vertex DepthOnlyVertex
		    #pragma fragment DepthOnlyFragment
		
		    #include "LWRP/ShaderLibrary/LightweightPassDepthOnly.hlsl"
		    ENDHLSL
		}
		
		// This pass it not used during regular rendering, only for lightmap baking.
		Pass
		{
		    Tags{"LightMode" = "Meta"}
		
		    Cull Off
		
		    HLSLPROGRAM
		    // Required to compile gles 2.0 with standard srp library
		    #pragma prefer_hlslcc gles
		
		    #pragma vertex LightweightVertexMeta
		    #pragma fragment LightweightFragmentMetaSimple
		
		    #pragma shader_feature _SPECULAR_SETUP
		    #pragma shader_feature _EMISSION
		    #pragma shader_feature _METALLICSPECGLOSSMAP
		    #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
		    #pragma shader_feature EDITOR_VISUALIZATION
		
		    #pragma shader_feature _SPECGLOSSMAP
		
		    #include "LWRP/ShaderLibrary/LightweightPassMeta.hlsl"
		    ENDHLSL
		}
	}
	
	FallBack "Hidden/InternalErrorShader"
}

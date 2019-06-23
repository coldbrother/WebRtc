//#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <Windows.h>

#include "../WebRtcMoudle/signal_processing_library.h"
#include "../WebRtcMoudle/noise_suppression_x.h"
#include "../WebRtcMoudle/noise_suppression.h"
#include "../WebRtcMoudle/gain_control.h"
//#include <>


void NoiseSuppression32(char *szFileIN,char *szFileOut,int nSample,int nMode,int buffersize )
{
    int nRet = 0 ; 
    NsHandle *pNS_inst = NULL;

    char *pInbuffer = NULL ; 
    char *pOutbuffer = NULL ;


//    nTime = GetTickCount()

    do{
        int i = 0  ;
        int nFileSize = 0 ; 
        int nTime = 0 ;
        
        if (0!= WebRtcNs_Create(&pNS_inst)){
            printf("Noise_Suppression WebRtcNs_Create err ! \n");
            break ; 
        }
        if (0 !=  WebRtcNs_Init(pNS_inst,nSample))
		{
			printf("Noise_Suppression WebRtcNs_Init err! \n");
			break;
		}

        if (0 != WebRtcNs_set_policy(pNS_inst,nMode)){
            printf("Noise_Suppression WebRtcNs_set_policy err !\n ");
            break ;
        }
        printf("szFileIN = %d\n",szFileIN[0]);
        pInbuffer = (char *) malloc(buffersize);
        memset(pInbuffer,0,buffersize);
        memcpy(pInbuffer, szFileIN, buffersize);

        pOutbuffer = (char *)malloc(buffersize);
        memset(pOutbuffer,0,buffersize);


        int filter_state1[6],filter_state12[6];
        int Synthesis_state1[6],Synthesis_state12[6];

		memset(filter_state1,0,sizeof(filter_state1));
		memset(filter_state12,0,sizeof(filter_state12));
		memset(Synthesis_state1,0,sizeof(Synthesis_state1));
		memset(Synthesis_state12,0,sizeof(Synthesis_state12));


		for (i = 0;i < buffersize;i+=640)
		{
			if (buffersize - i >= 640)
			{
				short shBufferIn[320] = {0};

				short shInL[160],shInH[160];
				short shOutL[160] = {0},shOutH[160] = {0};

				memcpy(shBufferIn,(char*)(pInbuffer+i),320*sizeof(short));
				//首先需要使用滤波函数将音频数据分高低频，以高频和低频的方式传入降噪函数内部
				WebRtcSpl_AnalysisQMF(shBufferIn,320,shInL,shInH,filter_state1,filter_state12);
                printf("shInL = %d \n",shInL[0]);
                printf("shInH = %d \n ",shInH[0]);

				//将需要降噪的数据以高频和低频传入对应接口，同时需要注意返回数据也是分高频和低频
				if (0 == WebRtcNs_Process(pNS_inst ,shInL  ,shInH ,shOutL , shOutH))
				{
					short shBufferOut[320];
                    printf("shOutH[0] = %d",shOutH[0]);
					//如果降噪成功，则根据降噪后高频和低频数据传入滤波接口，然后用将返回的数据写入文件
					WebRtcSpl_SynthesisQMF(shOutL,shOutH,160,shBufferOut,Synthesis_state1,Synthesis_state12);
					memcpy(pOutbuffer+i,shBufferOut,320*sizeof(short));
                    printf("shBufferOut[0] = %d \n ",shBufferOut[0]);
				}
			}	
		}
    }while(0);
    WebRtcNs_Free(pNS_inst);
    int i ; 
    for (i = 0 ; i < 10 ; i ++){
            printf("pOutbuffer[%d] = %d \n",i,pOutbuffer[i]);
    }
   
    memcpy(szFileOut,pOutbuffer,buffersize);
    free(pInbuffer);
    free(pOutbuffer);
}
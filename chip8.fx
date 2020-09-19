/*
    Chip8 emulator for ReShade by kingeric1992.
    https://en.wikipedia.org/wiki/CHIP-8

    note:
        getKey() in this impl is waiting for keyPressed, instead of keyReleased
*/
#include "VK.fxh"
/*
    todo: check getKey handling with timer
*/

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Custom Roms ( could use fxh to load)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// custom roms
static const uint tetris[] = {
    0xA2B423E6, 0x22B67001, 0xD0113025, 0x120671FF,
    0xD011601A, 0xD0116025, 0x3100120E, 0xC4704470,
    0x121CC303, 0x601E6103, 0x225CF515, 0xD0143F01,
    0x123CD014, 0x71FFD014, 0x2340121C, 0xE7A12272,
    0xE8A12284, 0xE9A12296, 0xE29E1250, 0x6600F615,
    0xF6073600, 0x123CD014, 0x7101122A, 0xA2C4F41E,
    0x66004301, 0x66044302, 0x66084303, 0x660CF61E,
    0x00EED014, 0x70FF2334, 0x3F0100EE, 0xD0147001,
    0x233400EE, 0xD0147001, 0x23343F01, 0x00EED014,
    0x70FF2334, 0x00EED014, 0x73014304, 0x6300225C,
    0x23343F01, 0x00EED014, 0x73FF43FF, 0x6303225C,
    0x233400EE, 0x80006705, 0x68066904, 0x611F6510,
    0x620700EE, 0x40E00000, 0x40C04000, 0x00E04000,
    0x40604000, 0x40406000, 0x20E00000, 0xC0404000,
    0x00E08000, 0x4040C000, 0x00E02000, 0x60404000,
    0x80E00000, 0x40C08000, 0xC0600000, 0x40C08000,
    0xC0600000, 0x80C04000, 0x0060C000, 0x80C04000,
    0x0060C000, 0xC0C00000, 0xC0C00000, 0xC0C00000,
    0xC0C00000, 0x40404040, 0x00F00000, 0x40404040,
    0x00F00000, 0xD0146635, 0x76FF3600, 0x133800EE,
    0xA2B48C10, 0x3C1E7C01, 0x3C1E7C01, 0x3C1E7C01,
    0x235E4B0A, 0x237291C0, 0x00EE7101, 0x1350601B,
    0x6B00D011, 0x3F007B01, 0xD0117001, 0x30251362,
    0x00EE601B, 0xD0117001, 0x30251374, 0x8E108DE0,
    0x7EFF601B, 0x6B00D0E1, 0x3F001390, 0xD0E11394,
    0xD0D17B01, 0x70013025, 0x13864B00, 0x13A67DFF,
    0x7EFF3D01, 0x138223C0, 0x3F0123C0, 0x7A0123C0,
    0x80A06D07, 0x80D24004, 0x75FE4502, 0x650400EE,
    0xA700F255, 0xA804FA33, 0xF265F029, 0x6D326E00,
    0xDDE57D05, 0xF129DDE5, 0x7D05F229, 0xDDE5A700,
    0xF265A2B4, 0x00EE6A00, 0x601900EE, 0x37230000
};
static const uint pong1[] = {
    0x6A026B0C, 0x6C3F6D0C, 0xA2EADAB6, 0xDCD66E00,
    0x22D46603, 0x68026060, 0xF015F007, 0x3000121A,
    0xC7177708, 0x69FFA2F0, 0xD671A2EA, 0xDAB6DCD6,
    0x6001E0A1, 0x7BFE6004, 0xE0A17B02, 0x601F8B02,
    0xDAB68D70, 0xC00A7DFE, 0x40007D02, 0x6000601F,
    0x8D02DCD6, 0xA2F0D671, 0x86848794, 0x603F8602,
    0x611F8712, 0x46021278, 0x463F1282, 0x471F69FF,
    0x47006901, 0xD671122A, 0x68026301, 0x807080B5,
    0x128A68FE, 0x630A8070, 0x80D53F01, 0x12A26102,
    0x80153F01, 0x12BA8015, 0x3F0112C8, 0x80153F01,
    0x12C26020, 0xF01822D4, 0x8E3422D4, 0x663E3301,
    0x660368FE, 0x33016802, 0x121679FF, 0x49FE69FF,
    0x12C87901, 0x49026901, 0x6004F018, 0x76014640,
    0x76FE126C, 0xA2F2FE33, 0xF265F129, 0x64146500,
    0xD4557415, 0xF229D455, 0x00EE8080, 0x80808080,
    0x80000000, 0x0000
};

#define _FLATTEN_

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  setup
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// type in ROM
#ifndef SELECT_ROM_
    #define SELECT_ROM_ pong1
#endif

// #ifndef BREAK_ON_INS
//     #define BREAK_ON_INS 0NNN
// #endif


// #define _GETINS(a) _ ## a
// #define GETINS(a) _GETINS()

// #define BREAK_0NNN

// bool break_on_ins(uint op) {



// }

/*
    default keymap:
        ╔═══╦═══╦═══╦═══╗   ╔═══╦═══╦═══╦═══╗
        ║ 1 ║ 2 ║ 3 ║ C ║   ║ 1 ║ 2 ║ 3 ║ 4 ║
        ╠═══╬═══╬═══╬═══╣   ╠═══╬═══╬═══╬═══╣
        ║ 4 ║ 5 ║ 6 ║ D ║   ║ Q ║ W ║ E ║ R ║
        ╠═══╬═══╬═══╬═══╣   ╠═══╬═══╬═══╬═══╣
        ║ 7 ║ 8 ║ 9 ║ E ║   ║ A ║ S ║ D ║ F ║
        ╠═══╬═══╬═══╬═══╣   ╠═══╬═══╬═══╬═══╣
        ║ A ║ 0 ║ B ║ F ║   ║ Z ║ X ║ C ║ V ║
        ╚═══╩═══╩═══╩═══╝   ╚═══╩═══╩═══╩═══╝
    https://github.com/mattmikolay/chip-8/wiki/CHIP-8-Technical-Reference
*/
#define KEYCODE_PAUSE   VK_SPACE
#define KEYCODE_NEXT    VK_RIGHT

#define KEYCODE_1       VK_1
#define KEYCODE_2       VK_2
#define KEYCODE_3       VK_3
#define KEYCODE_C       VK_4

#define KEYCODE_4       VK_Q
#define KEYCODE_5       VK_W
#define KEYCODE_6       VK_E
#define KEYCODE_D       VK_R

#define KEYCODE_7       VK_A
#define KEYCODE_8       VK_S
#define KEYCODE_9       VK_D
#define KEYCODE_E       VK_F

#define KEYCODE_A       VK_Z
#define KEYCODE_0       VK_X
#define KEYCODE_B       VK_C
#define KEYCODE_F       VK_V

// screen space coord (norm)
static const float4 gStatRect = float4(0.8,0.1,  0.8 + 0.1 * (BUFFER_HEIGHT * BUFFER_RCP_WIDTH),0.2); // TR
static const float4 gRegRect  = float4(0.8,0.21, 0.8 + 0.2 * (BUFFER_HEIGHT * BUFFER_RCP_WIDTH),0.3); // TR
static const float4 gViewRect = float4(0.1,0.1, 0.7,0.9); // LEFT

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  controls
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform bool ui_debug = false;

// start/pause
uniform bool key_pause < source = "key"; keycode = KEYCODE_PAUSE; mode = "toggle"; >;
uniform bool key_next  < source = "key"; keycode = KEYCODE_NEXT;  mode = "press"; >;

// keydown
uniform bool keyDown_1 < source = "key"; keycode = KEYCODE_1; >;
uniform bool keyDown_2 < source = "key"; keycode = KEYCODE_2; >;
uniform bool keyDown_3 < source = "key"; keycode = KEYCODE_3; >;
uniform bool keyDown_C < source = "key"; keycode = KEYCODE_C; >;
uniform bool keyDown_4 < source = "key"; keycode = KEYCODE_4; >;
uniform bool keyDown_5 < source = "key"; keycode = KEYCODE_5; >;
uniform bool keyDown_6 < source = "key"; keycode = KEYCODE_6; >;
uniform bool keyDown_D < source = "key"; keycode = KEYCODE_D; >;
uniform bool keyDown_7 < source = "key"; keycode = KEYCODE_7; >;
uniform bool keyDown_8 < source = "key"; keycode = KEYCODE_8; >;
uniform bool keyDown_9 < source = "key"; keycode = KEYCODE_9; >;
uniform bool keyDown_E < source = "key"; keycode = KEYCODE_E; >;
uniform bool keyDown_A < source = "key"; keycode = KEYCODE_A; >;
uniform bool keyDown_0 < source = "key"; keycode = KEYCODE_0; >;
uniform bool keyDown_B < source = "key"; keycode = KEYCODE_B; >;
uniform bool keyDown_F < source = "key"; keycode = KEYCODE_F; >;

// pressed
uniform bool keyPressed_1 < source = "key"; keycode = KEYCODE_1; mode = "press";>;
uniform bool keyPressed_2 < source = "key"; keycode = KEYCODE_2; mode = "press";>;
uniform bool keyPressed_3 < source = "key"; keycode = KEYCODE_3; mode = "press";>;
uniform bool keyPressed_C < source = "key"; keycode = KEYCODE_C; mode = "press";>;
uniform bool keyPressed_4 < source = "key"; keycode = KEYCODE_4; mode = "press";>;
uniform bool keyPressed_5 < source = "key"; keycode = KEYCODE_5; mode = "press";>;
uniform bool keyPressed_6 < source = "key"; keycode = KEYCODE_6; mode = "press";>;
uniform bool keyPressed_D < source = "key"; keycode = KEYCODE_D; mode = "press";>;
uniform bool keyPressed_7 < source = "key"; keycode = KEYCODE_7; mode = "press";>;
uniform bool keyPressed_8 < source = "key"; keycode = KEYCODE_8; mode = "press";>;
uniform bool keyPressed_9 < source = "key"; keycode = KEYCODE_9; mode = "press";>;
uniform bool keyPressed_E < source = "key"; keycode = KEYCODE_E; mode = "press";>;
uniform bool keyPressed_A < source = "key"; keycode = KEYCODE_A; mode = "press";>;
uniform bool keyPressed_0 < source = "key"; keycode = KEYCODE_0; mode = "press";>;
uniform bool keyPressed_B < source = "key"; keycode = KEYCODE_B; mode = "press";>;
uniform bool keyPressed_F < source = "key"; keycode = KEYCODE_F; mode = "press";>;

bool keyDown(uint d) {
    bool down[16] = {
        keyDown_0, keyDown_1, keyDown_2, keyDown_3,
        keyDown_4, keyDown_5, keyDown_6, keyDown_7,
        keyDown_8, keyDown_9, keyDown_A, keyDown_B,
        keyDown_C, keyDown_D, keyDown_E, keyDown_F
    };
    return down[d];
}
bool keyPressed(uint d) {
    bool pressed[16] = {
        keyPressed_0, keyPressed_1, keyPressed_2, keyPressed_3,
        keyPressed_4, keyPressed_5, keyPressed_6, keyPressed_7,
        keyPressed_8, keyPressed_9, keyPressed_A, keyPressed_B,
        keyPressed_C, keyPressed_D, keyPressed_E, keyPressed_F
    };
    return pressed[d];
}

uniform uint   gFrame  < source = "framecount"; >;
// uniform float gTimer  < source = "timer"; >;
uniform bool   gEditor < source = "overlay_open"; >;
uniform uint   gRND    < source = "random"; min = 0; max = 0xFF; >;
uniform bool   gLMB    < source = "mousebutton"; keycode = 0; mode = "press";>;
uniform float2 gMseUV  < source = "mousepoint"; >;

bool hovered( float4 rect ) { return all(gMseUV > rect.xy && gMseUV < rect.zw); }

bool pause() { return key_pause /*|| gEditor*/;  }
bool debug() { return ui_debug;   } // toggle button.
bool next()  { return key_next;   }

static const float2 gScreenSize = float2(BUFFER_WIDTH, BUFFER_HEIGHT);
static const float2 gAspect2    = float2(BUFFER_WIDTH * BUFFER_RCP_HEIGHT, 1);

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Memory Init
//  Char        (First 80 byte in the memory)
//  Program     (load rom into 0x200)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define ADDR_CHAR 0 // font is saved in 0x000 ~ 0x200 in game memory
#define ADDR_PROG 0x200

// 4x5 bitfield each. stride = 5
static const uint charSprites[80] = {
    0xF0, 0x90, 0x90, 0x90, 0xF0, //0
    0x20, 0x60, 0x20, 0x20, 0x70, //1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, //2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, //3
    0x90, 0x90, 0xF0, 0x10, 0x10, //4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, //5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, //6
    0xF0, 0x10, 0x20, 0x40, 0x40, //7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, //8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, //9
    0xF0, 0x90, 0xF0, 0x90, 0x90, //A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, //B
    0xF0, 0x80, 0x80, 0x80, 0xF0, //C
    0xE0, 0x90, 0x90, 0x90, 0xE0, //D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, //E
    0xF0, 0x80, 0xF0, 0x80, 0x80  //F
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  resources
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// output target.

#define REG_WIDTH ( 40 ) // 16 VN, 4 regs, 1+19 stack
#define MEM_WIDTH ( 4096 )

// VN[16], STACK[16], SP(32), CP(33), I(34), FLAG(35), Timer(36) /* disp() or disp_clear() */
texture texRegA  { Width = REG_WIDTH; Format = RG8;  }; // x is hi, y is lo
texture texRegB  { Width = REG_WIDTH; Format = RG8;  };
texture texMem   { Width = 4096;      Format = R8;   };
texture texFront { Width = 64; Height = 32; Format = R8;};
texture texBack  { Width = 64; Height = 32; Format = R8;};

#define ADDRESS( a ) AddressU = a; AddressV = a; AddressW = a
#define FILTER( a )  MagFilter = a; MinFilter = a; MipFilter = a

sampler sampBack  { Texture = texBack;  ADDRESS(BORDER); FILTER(POINT); };
sampler sampFront { Texture = texFront; ADDRESS(BORDER); FILTER(POINT); };
sampler sampMem   { Texture = texMem;   ADDRESS(BORDER); FILTER(POINT); };
sampler sampRegA  { Texture = texRegA;  ADDRESS(BORDER); FILTER(POINT); };
sampler sampRegB  { Texture = texRegB;  ADDRESS(BORDER); FILTER(POINT); };

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  helpers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#define LOW4(a)     ((a) % 0x10)
#define LOW8(a)     ((a) % 0x100)
#define LOW12(a)    ((a) % 0x1000)
#define LOW(a)      LOW8(a)

uint  uint16( uint2 bytes )     { return (bytes.x << 8) + bytes.y; }
uint  uint16( uint a, uint b)   { return (a << 8) + b; }
uint2 bytes( uint v )           { return LOW(uint2( v >> 8, v)); }
uint4 split32( uint a )         { return uint4( a >> 24, a >> 16, a >> 8, a); }
uint4 split8(uint a)            { return uint4( a >> 6,  a >> 4,  a >> 2, a); } // big-endian

// 8 bit.
uint and8( uint A, uint B ) {
    uint4 a = split8(A)%4, b = split8(B)%4, c = (a>b ? b:a) - (a*b == 2);
    return dot(c << uint4(6,4,2,0),1);
}
uint or8( uint A, uint B ) {
    uint4 a = split8(A)%4, b = split8(B)%4, c = (a>b ? a:b) + (a*b == 2);
    return dot(c << uint4(6,4,2,0),1);
}
uint xor8( uint A, uint B ) {
    uint4 a = split8(A)%4, b = split8(B)%4, c = (a>b ? a-b:b-a) + (a*b == 2)*2;
    return dot(c << uint4(6,4,2,0),1);
}

#if (__RENDERER__ == 0x9000)
    #define AND(a,b) and8(a,b)
    #define OR(a,b)  or8(a,b)
    #define XOR(a,b) xor8(a,b)
#else
    #define AND(a,b) ((a)&(b))
    #define OR(a,b)  ((a)|(b))
    #define XOR(a,b) ((a)^(b))
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Registers
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define ADDR_VN 0                   // data regs. 8bit each
#define ADDR_CP 16                  // prog ptr
#define ADDR_I  17                  // address reg, 16bit (12 tops)
#define ADDR_OP 18                  // deferred opcode., 16bit for deferred ops
#define ADDR_T  19                  // timer, 8bit
#define ADDR_SP 20                  // stack ptr
#define ADDR_ST 21                  // stack



// bypass for global static
// float gOffset(float v, bool set )   { static float _v; if(set) _v = v; return _v;  }
// float gOffset()                     { return gOffset(0,false); }
// void  gOffset(float v)              { gOffset(v, true); } // updated value.
// uint2 gWrites(uint2 v, bool set )   { static uint2 _v; if(set) _v = v; return _v;  }
// uint2 gWrites()                     { return gWrites(0,false); }
// void  gWrites(uint2 v)              { gWrites(v, true); } // updated reg offset.

/*
    no static variable type, passing val through function arg is the only way
*/


// void  _set( uint addr, uint v)      { gOffset((.5+addr)/(.5*REG_WIDTH)-1.), gWrites(bytes(v)); }
// void  _set_lo( uint addr, uint v)   { gOffset((.5+addr)/(.5*REG_WIDTH)-1.), gWrites(uint2(0,LOW(v))); }

#define _set(a,b)                   { vo.x = (a), vo.y = (b); }
#define _set_lo(a,b)                { vo.x = (a), vo.y = LOW((b)); }
#define OUT inout uint2 vo

uint  _get_lo(   uint addr)         { return tex2Dfetch(sampRegA, int4(addr,0,0,0)).y * 0xFF; }
uint  _get(      uint addr )        { return uint16(tex2Dfetch(sampRegA, int4(addr,0,0,0)).xy * 0xFF ); }
uint  _getB(     uint addr )        { return uint16(tex2Dfetch(sampRegB, int4(addr,0,0,0)).xy * 0xFF ); }
uint  _mem(      uint addr )        { return tex2Dfetch(sampMem, int4(addr,0,0,0)).x * 0xFF; }
uint  _frame(    uint X, uint Y )   { return tex2Dfetch(sampBack,int4(X,Y,0,0)).x * 0xFF; }
uint  _opcode(   uint addr)         { return uint16(_mem(addr),_mem(++addr)); }

// 16bit getters
uint CP()                           { return _get(ADDR_CP); }
uint I()                            { return _get(ADDR_I); }
uint SP()                           { return _get(ADDR_SP); }
uint ST()                           { return _get(ADDR_ST + SP() - 1); } // pop stack (pre SP decrement)
uint OP()                           { return _get(ADDR_OP); }
uint OPB()                          { return _getB(ADDR_OP); }  // get OP (for deferred op)
// 8bit getters
uint T()                            { return _get_lo(ADDR_T); }
uint VF()                           { return _get_lo(ADDR_VN + 15); }
uint VN(uint d)                     { return _get_lo(ADDR_VN + d); }
uint VX(uint d)                     { return _get_lo(ADDR_VN + LOW4(d >> 8)); }
uint VY(uint d)                     { return _get_lo(ADDR_VN + LOW4(d >> 4)); }
// 16bit setters
void CP(OUT, uint v)                { _set(ADDR_CP, v); }
void I( OUT, uint v)                { _set(ADDR_I, v);  }
void SP(OUT, uint v)                { _set(ADDR_SP, v); }
void ST(OUT, uint v)                { _set(ADDR_ST + SP(), v); } // push stack (pre SP increment)
void OP(OUT, uint v)                { _set(ADDR_OP, v); }
// 8bit setters
void T( OUT,uint v)                 { _set_lo(ADDR_T, v); }
void VF(OUT,uint v)                 { _set_lo(ADDR_VN + 15, v); }
void VN(OUT,uint d, uint v)         { _set_lo(ADDR_VN + d, v); }
void VX(OUT,uint d, uint v)         { _set_lo(ADDR_VN + LOW4(d >> 8), v); }
void VY(OUT,uint d, uint v)         { _set_lo(ADDR_VN + LOW4(d >> 4), v); }
// char gettter
uint CHR(uint d )                   { return ADDR_CHAR + d*5;}
// key getters
uint KEY(uint d)                    { return keyDown(d); }
uint KEY() { // favors smaller index, triggered by key release.
    if(keyPressed(0x0)) return 0x01;
    if(keyPressed(0x1)) return 0x02;
    if(keyPressed(0x2)) return 0x03;
    if(keyPressed(0x3)) return 0x04;
    if(keyPressed(0x4)) return 0x05;
    if(keyPressed(0x5)) return 0x06;
    if(keyPressed(0x6)) return 0x07;
    if(keyPressed(0x7)) return 0x08;
    if(keyPressed(0x8)) return 0x09;
    if(keyPressed(0x9)) return 0x0A;
    if(keyPressed(0xA)) return 0x0B;
    if(keyPressed(0xB)) return 0x0C;
    if(keyPressed(0xC)) return 0x0D;
    if(keyPressed(0xD)) return 0x0E;
    if(keyPressed(0xE)) return 0x0F;
    if(keyPressed(0xF)) return 0x10;
    return 0;
}
#undef _set
#undef _set_lo



//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Display instructions (vs_draw)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float4 _disp( uint vid) {                   // clear
    return float4(vid.xx == uint2(2,1)? float2(-3,3):float2(1,-1),0,1);
}
float4 _disp( uint vid, inout int3 TL) {   // quad
    uint h  = LOW4(TL.z);                   // still need to check how much should it render
    TL.x = VX(TL.z) % 0x40, TL.y = VY(TL.z) % 0x20;
// render 16xN quad instead of 8xN to pack 8bit to the right in single fetch.
    return float4((TL.x + ((vid/2)?-8:8))/32.-1., 1.-(TL.y + (vid%2)*h)/16.,0,1);
}
void _disp( OUT, int op)   {               // set VF when display fliped (vs_run)
    uint len = LOW4(op), X=VX(op)%0x40, i=0, Y=VY(op)%0x20, addr=I();
    // [unroll]
    // for( int i=0, Y=VY(op)%0x20, addr=I(); i<16 && i<len; i++)
    //     if (AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }

    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    [flatten] if((i++ < len) && AND(_frame(X,Y++),_mem(addr++))) { VF(vo,1); return; }
    VF(vo,0);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Memory Instructions
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// mem -> reg ( vs_read )
float4 _mem_load( uint vid, inout uint addr) {  // FX65:
    uint len = LOW4(addr >> 8) + 1;
    addr = I();
    return float4((vid*len)/(.5*REG_WIDTH) - 1,0,0,1);
}
// reg -> mem ( vs_write )
float4 _mem_dump(uint vid, inout uint2 addr) {  // FX55:
    uint len = LOW4(addr.y >> 8) + 1; // F155
    addr.x = I(), addr.y = LOW(addr.y);
    return float4((addr.x + vid*len)/(.5*MEM_WIDTH) - 1,0,0,1);
}
// reg -> mem ( vs_write )
float4 _mem_bcd(uint vid, inout uint3 addr) {   // FX33(BSD)
    addr.z = VX(addr.y), addr.y = LOW(addr.y), addr.x = I();
    return float4((addr.x + vid*3)/(.5*MEM_WIDTH) - 1,0,0,1);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Register Instructions (Flow Control)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void _continue( OUT)            { CP(vo,CP()+2); }
void _call2(    OUT,uint op)    { CP(vo,LOW12(op)); }
void _sub_ret2( OUT)            { CP(vo,ST()+2); }
void _sub_call2(OUT,uint op)    { CP(vo,LOW12(op)); }
void _goto(     OUT,uint op)    { CP(vo,LOW12(op)); }
void _jmp(      OUT,uint op)    { CP(vo,VN(0) + LOW12(op)); }
void _cond_eq(  OUT,uint op)    { CP(vo,CP()+(VX(op) == LOW(op)? 4:2)); }
void _cond_ne(  OUT,uint op)    { CP(vo,CP()+(VX(op) != LOW(op)? 4:2)); }
void _cond_req( OUT,uint op)    { CP(vo,CP()+(VX(op) == VY(op)?  4:2)); }
void _cond_rne( OUT,uint op)    { CP(vo,CP()+(VX(op) != VY(op)?  4:2)); }
void _key_req(  OUT,uint op)    { CP(vo,CP()+(KEY(LOW4(VX(op)))? 4:2)); }
void _key_rne(  OUT,uint op)    { CP(vo,CP()+(KEY(LOW4(VX(op)))? 2:4)); }
void _key_get2( OUT,uint op)    { [flatten] if(KEY()) CP(vo,CP() + 2);  } // halt until getKey()

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Register Instructions
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void _time_run( OUT)            { [flatten] if(T() > 0) T(vo,T() - 1); }
void _rnd(      OUT,uint op)    { VX(vo, op, AND(gRND,LOW(op))); }

void _sub_ret0( OUT)            { SP(vo,SP() - 1); }       // decrement SP
void _sub_call0(OUT)            { SP(vo,SP() + 1); }       // increment SP
void _sub_call1(OUT)            { ST(vo,CP()); }           // push CP to call stack
void _call0(    OUT)            { SP(vo,SP() + 1); }       // increment SP
void _call1(    OUT)            { ST(vo,CP()); }           // push CP to call stack

void _const(    OUT,uint op)    { VX(vo,op,LOW(op)); }
void _const_add(OUT,uint op)    { VX(vo,op,VX(op) + op); }
void _assign(   OUT,uint op)    { VX(vo,op,VY(op)); }

void _bit_or(   OUT,uint op)    { VX(vo,op,OR( VX(op),VY(op))); }
void _bit_and(  OUT,uint op)    { VX(vo,op,AND(VX(op),VY(op))); }
void _bit_xor(  OUT,uint op)    { VX(vo,op,XOR(VX(op),VY(op))); }

void _bit_rs0(  OUT,uint op)    { VX(vo,op, VX(op) >> 1); }
void _bit_ls0(  OUT,uint op)    { VX(vo,op, VX(op) << 1); }
void _bit_rs1(  OUT,uint op)    { VF(vo,VX(op) %  2); }     // save LSB to VF
void _bit_ls1(  OUT,uint op)    { VF(vo,VX(op) >> 7); }     // save MSB to VF

void _math_add0( OUT,uint op)   { VX(vo,op,VX(op)+VY(op)); }
void _math_add1( OUT,uint op)   { [flatten] if ((VX(op) + VY(op)) > 0xFF ) VF(vo,1); } // set VF to 1 if carry
void _math_sub0( OUT,uint op)   { VX(vo,op,LOW(VX(op)-VY(op))); }
void _math_sub1( OUT,uint op)   { [flatten] if (VX(op) < VY(op)) VF(vo,0); } // set VF to 0 if borrow
void _math_rsub0(OUT,uint op)   { VX(vo,op,LOW(VY(op)-VX(op))); }
void _math_rsub1(OUT,uint op)   { [flatten] if ( VY(op) < VX(op)) VF(vo,0); } // set VF to 0 if borrow

void _mem_set(  OUT,uint op)    { I(vo,LOW12(op)); }
void _mem_add(  OUT,uint op)    { I(vo,I() + VX(op)); }
void _mem_chr(  OUT,uint op)    { I(vo,CHR(LOW4(VX(op)))); }

// (Blocking Operation. All instruction halted until next key event)
// A key press is awaited, and then stored in VX. (1 based)
void _key_get0( OUT,uint op)    { [flatten] if(KEY()) VX(vo,op,KEY()-1); }
void _time_get( OUT,uint op)    { VX(vo,op,T()); }
void _time_set( OUT,uint op)    { T(vo,LOW(VX(op))); }
void _time_fx(  OUT,uint op)    { /**/ }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Cycle
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// handles timer;
void cmd3( OUT, uint op ) {
    // if opcode is await key & no key present -> halt.
    _FLATTEN_ if( ((op >> 12) != 0xF) || (LOW(op) != 0x0A)) _time_run(vo);
}
// handles CP access
void cmd2( OUT, uint op ) {
    _FLATTEN_
    switch( op >> 12) {
    default:  _continue(vo);    break; // CP += 2;
    case 0xB: _jmp(     vo,op); break;
    case 0x1: _goto(    vo,op); break;
    case 0x2: _sub_call2(vo,op);break;
    case 0x3: _cond_eq( vo,op); break;
    case 0x4: _cond_ne( vo,op); break;
    case 0x5: _cond_req(vo,op); break;
    case 0x9: _cond_rne(vo,op); break;
    case 0x0: {
        _FLATTEN_ if (op == 0x00EE) _sub_ret2(vo);
        _FLATTEN_ if (op == 0x00E0) _continue(vo);
        // else: 0NNN, non-impl
    } break;
    case 0xF: {
        _FLATTEN_ if (LOW(op) == 0x0A) _key_get2(vo,op); // cond add cp
        else _continue(vo);
    } break;
    case 0xE: {
        _FLATTEN_
        if (LOW(op) ==  0x9E) _key_req(vo,op);
        else _key_rne(vo,op);
    } break;
    }
}
// not doing too much thing.
void cmd1( OUT, uint op ) {
    _FLATTEN_
    switch( op >> 12) {
    case 0x2: _sub_call1(vo); break;
    case 0x8: {
        _FLATTEN_
        switch(LOW4(op)) {
        case 0x6: _bit_rs1(   vo,op); break;
        case 0xE: _bit_ls1(   vo,op); break;
        case 0x4: _math_add1( vo,op); break;
        case 0x5: _math_sub1( vo,op); break;
        case 0x7: _math_rsub1(vo,op); break;
        }
    } break;
    }
}


void cmd0( OUT, uint op ) {
    _FLATTEN_
    switch(op >> 12)
    {
    case 0: {
        _FLATTEN_ if (op == 0xEE) _sub_ret0(vo);
    } break;
    case 2: _sub_call0( vo);    break;
    case 6: _const(     vo,op); break;
    case 7: _const_add( vo,op); break;
    case 8: {
        _FLATTEN_
        switch(LOW4(op)) {
        case 0x0: _assign(    vo,op); break;
        case 0x1: _bit_or(    vo,op); break;
        case 0x2: _bit_and(   vo,op); break;
        case 0x3: _bit_xor(   vo,op); break;
        case 0x6: _bit_rs0(   vo,op); break;
        case 0xE: _bit_ls0(   vo,op); break;
        case 0x4: _math_add0( vo,op); break;
        case 0x5: _math_sub0( vo,op); break;
        case 0x7: _math_rsub0(vo,op); break;
        }
    } break;
    case 0xA: _mem_set(vo,op); break;
    case 0xC: _rnd(    vo,op); break;
    case 0xD: _disp(   vo,op); break; // this will set VF accordingly
    case 0xF: {
        _FLATTEN_
        switch(LOW(op)) {
            case 0x07: _time_get(vo,op); break;
            case 0x15: _time_set(vo,op); break;
            case 0x0A: _key_get0(vo,op); break;
            // case 0x18: _time_fx( vo,op); break; // not impl
            case 0x1E: _mem_add( vo,op); break;
            case 0x29: _mem_chr( vo,op); break;
            // case 0x33: _mem_bcd( vo,op); break; // vs_write
            // case 0x55: _mem_dump(vo,op); break; // vs_write
            // case 0x65: _mem_load(vo,op); break; // vs_read
        }
    } break;
    }
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Default Rom
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// test rom.
static const uint rom_chip8_pic[41] = {
//    00  02      04  06      08  0A      0C  0E
    0x00E0A248, 0x6000611E, 0x6200D202, 0xD2127208, //0x200 (D202,D212) // I = 0x248, V0 = 00, V1 = 1E, V2 = 00,
    0x3240120A, 0x6000613E, 0x6202A24A, 0xD02ED12E, //0x210 D02E D12E   // I = 0x24A, v0 = 00, V1 = 3E, V2 = 02
    0x720ED02E, 0xD12EA258, 0x600B6108, 0xD01F700A, //0x220
    0xA267D01F, 0x700AA276, 0xD01F7003, 0xA285D01F, //0x230
    0x700AA294, 0xD01F1246, 0xFFFFC0C0, 0xC0C0C0C0, //0x240 (0x1246) // end of program.
    0xC0C0C0C0, 0xC0C0C0C0, 0xFF808080, 0x80808080,
    0x80808080, 0x8080FF81, 0x81818181, 0x8181FF81,
    0x81818181, 0x81818080, 0x80808080, 0x80808080,
    0x80808080, 0x80FF8181, 0x81818181, 0xFF808080,
    0x80808080, 0xFF818181, 0x818181FF, 0x81818181,
    0x8181FFFF
};

static const uint rom_keypad_test[] = {
    0x124E0819, 0x01010801, 0x0F010109, 0x08090F09, //200
    0x01110811, 0x0F110119, 0x0F191601, 0x16091611, //210
    0x1619FCFC, 0xFCFCFCFC, 0xFC00A202, 0x820EF21E, //220
    0x8206F165, 0x00EEA202, 0x820EF21E, 0x8206F155, //230
    0x00EE6F10, 0xFF15FF07, 0x3F001246, 0x00EE00E0, //240
    0x6200222A, 0xF229D015, 0x70FF71FF, 0x22367201, //
    0x32101252, 0xF20A222A, 0xA222D017, 0x2242D017,
    0x12640000
};

static const uint rom_delay_time_test[] = {
    0x6601221E, 0xF40A4402, 0x73014408, 0x83653405,
    0x1202F315, 0xF307221E, 0x33001214, 0x120200E0,
    0x6500A23A, 0xF333F265, 0xF029D565, 0xF1296505,
    0xD565F229, 0x650AD565, 0x00EE0000
};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Flows. (init, pause, step through)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// #define SET(a) 1
// #if !(SELECT_ROM_ + 0) // not found
//     #undef SELECT_ROM_
//     #define SELECT_ROM_ rom_chip8_pic
// #else
//     #undef SET
//     #define SET(a) a // revert name
// #endif


// write starting pos to reg
float2 ps_reg_init( uint4 vpos ) {
    return ((vpos.x == ADDR_CP) * bytes(ADDR_PROG) +
            (vpos.x == ADDR_OP) * bytes(0xE0)) /float(0xFF);
}
float  ps_mem_init( uint4 vpos ) {
    int prog = vpos.x - ADDR_PROG, chr = vpos.x - ADDR_CHAR;
    uint rom  = split32( SELECT_ROM_[prog / 4] )[prog % 4];

    return ( prog < 0 ? charSprites[chr]:LOW(rom)  ) / float(0xFF);
}
bool    init()      { return CP() < 0x200; } // CP should not be in the reserved space.
bool    delay()     { return (gFrame % 60); }
bool    halt( uint op)    { // halt
    // cond:
    //bool cond = (op >> 12) == 0xD; //
    bool cond = LOW(op) == 0x55;
    return pause() || (debug() && !next());
}

#define HALT(op)    if (halt(op)) return float4(0,0,-2,1)
#define DELAY()     //if (delay()) return float4(0,0,-2,1) //slowmo
#define LIN_INIT(a) if (init())  return float4((a)*2.-1,0,0,1)  // init buffer
#define RUN_INIT(a) if (init())  return float4(0,0,-2,1)        // bypass
#define REG_INIT(a) if (init())  return ps_reg_init(a)
#define MEM_INIT(a) if (init())  return ps_mem_init(a)

#undef OUT
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Main Loop
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float4 vs_run( uint vid : SV_VERTEXID, nointerpolation out uint2 arg : TEXCOORD ) : SV_POSITION {
    arg = 0;
    uint  op = _opcode(CP());
    uint2 vo = uint2(100,0);

    if(vid) // always prepare ADDR_OP even if halt.
        HALT(op);

    RUN_INIT(); // bypass
    DELAY();


    //if ( ((op >> 12) == 0xF) && (LOW(op) == 0x29) && !next() ) return float4(0,0,-2,1);

    //if (!debug() && next()) {
    _FLATTEN_
    switch( vid ) {
    case 0: OP(  vo,op); break; // push opcode to ADDR_OP
    case 1: cmd0(vo,op); break; // ins0
    case 2: cmd1(vo,op); break; // ins1
    case 3: cmd2(vo,op); break; // CP
    case 4: cmd3(vo,op); break; // Timer
    }
    arg = bytes(vo.y);
    return float4((.5+vo.x)/(.5*REG_WIDTH)-1.,0,0,1);
}
float2 ps_run( float4 vpos : SV_POSITION, nointerpolation uint2 arg : TEXCOORD ) : SV_TARGET {
    return arg/float(0xFF);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Memory Access ( MEM -> REG )
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// read mem, write reg (regA -> regB)
float4 vs_read( uint vid : SV_VERTEXID, nointerpolation out uint addr : TEXCOORD ) : SV_POSITION {
    addr = _opcode(CP()); // can't use OPB cause writing to regB

    HALT(addr);
    LIN_INIT(vid); // init buffer.
    DELAY();

    if(((addr >> 12) == 0xF) && (LOW(addr) == 0x65)) // FX65
        return _mem_load(vid, addr);

    return float4(0,0,-2,1);
}
float2 ps_read( float4 vpos : SV_POSITION, nointerpolation uint addr : TEXCOORD ) : SV_TARGET {
    REG_INIT(vpos);
    return float2(0, _mem( addr + trunc(vpos.x))/float(0xFF));
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Memory Access ( REG -> MEM )
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// read reg, write mem;
float4 vs_write( uint vid : SV_VERTEXID, nointerpolation out uint3 addr : TEXCOORD ) : SV_POSITION {
    addr.y = OPB(); // OPB cause & can't read mem

    HALT(addr.y);
    LIN_INIT(vid);  // init buffer
    DELAY();

    switch (LOW(addr.y)) {
    case 0x55:  return _mem_dump(vid,addr.xy); //FX55
    case 0x33:  return _mem_bcd(vid,addr);  //FX33 (BSD)
    default:    return float4(0,0,-2,1);
    }
}
float ps_write( float4 vpos : SV_POSITION, nointerpolation uint3 addr : TEXCOORD ) : SV_TARGET {
    MEM_INIT(vpos); // load font, rom
// 514,85,0
    addr.x = floor(vpos.x) - addr.x;
    switch(addr.y) {
    case 0x55:  return VN(addr.x)/float(0xFF);
    case 0x33:  return uint3(addr.z/100, (addr.z/10) % 10, addr.z % 10)[addr.x]/float(0xFF);
    default:    return 0;
    }
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Draw
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float4 vs_draw( uint vid : SV_VERTEXID, nointerpolation out int3 TL : TEXCOORD ) : SV_POSITION {
    TL = OPB();

    HALT(TL.z);
    RUN_INIT(); // bypass
    DELAY();

    if (TL.z == 0xE0)           return _disp(vid);       // disp_clear
    if ((TL.z >> 12) == 0xD )   return _disp(vid, TL);   // disp
    else                        return float4(0,0,-2,1); // bypassed
}
float ps_draw( float4 vpos : SV_POSITION, nointerpolation int3 TL : TEXCOORD ) : SV_TARGET {
    if(TL.z == 0xE0) return 0; // disp_clear;
    TL.xy    = floor(vpos.xy) - TL.xy;
    int dest = tex2Dfetch(sampFront, vpos.xyzz).x * 0xFF;
    int src  = _mem( I() + TL.y );
    return LOW(XOR( (TL.x > 0) ?(src << TL.x):(src >> -TL.x), dest))/float(0xFF);
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader WriteBack
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// should we do conditional update by src buffer?
float4 vs_lineCopy( uint vid : SV_VERTEXID ) : SV_POSITION {
    HALT(OPB());
    DELAY();
    return float4( vid*2.-1.,0,0,1);
}
float2 ps_lineCopy( float4 vpos : SV_POSITION ) : SV_TARGET {
    return tex2Dfetch(sampRegB, vpos.xyzz).xy;
}
float4 vs_copy( uint vid : SV_VERTEXID ) : SV_POSITION {
    HALT(OPB());
    RUN_INIT();
    DELAY();
    return float4((vid.xx == uint2(2,1)? float2(-3,3):float2(1,-1)), 0,1);
}
float2 ps_copy( float4 vpos : SV_POSITION ) : SV_TARGET {
    return tex2Dfetch(sampBack, vpos.xyzz).xy;
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Present
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// uv for different mapping mode. stretch, clip, centered
float4 vs_present( uint vid : SV_VERTEXID, out float4 uv : TEXCOORD0 ) : SV_POSITION {
    uv.xy = vid.xx == uint2(2,1)? (2.).xx:(0.).xx;
    uv.zw = (uv.xy - gViewRect.xy) / (gViewRect.zw - gViewRect.xy);
    return float4( uv.x*2-1, 1.-uv.y*2, 0,1);
}
float4 ps_present( float4 vpos : SV_POSITION, float4 uv : TEXCOORD0 ) : SV_TARGET {
    float3 tint = uint(tex2D(sampBack, uv.zw).r * 0xFF) >> 7; // MSB is the display data.
    return float4(tint,  0.75 + all( 0 < uv.zw && uv.zw < 1 ) );
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Status
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

float4 vs_status( uint vid : SV_VERTEXID, out float2 uv : TEXCOORD0 ) : SV_POSITION {
    float4 rect = gStatRect*2. - 1.;
    rect.yw *= -1.;

    if (!pause() && !debug())   // triangle play icon
        return float4( vid.x<1.5 ? rect.x:rect.z, float3(rect.yw,dot(rect.yw,.5))[vid],  0,1);

    // quad, circle
    uv      = (vid.xx == uint2(2,1))? (2.).xx:(0).xx;
    rect    = float4( lerp(rect.xy, rect.zw, uv) ,0,1);
    uv      = (uv-.5);
    return rect;
}
float4 ps_status( float4 vpos : SV_POSITION, float2 uv : TEXCOORD0 ) : SV_TARGET {
    if (pause())    return float4(1,0,0, all(abs(uv) < .5 ));    // red block
    if (debug())    return float4(1,0,0, length(uv) < .5 );      // red circle
    else            return float4(0, LOW(CP())/float(0xFF),0,1); // green triangle
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Shader Debug (CP, op)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


float4 vs_debug(uint vid : SV_VERTEXID, out float4 uv : TEXCOORD) : SV_POSITION {
    float4 rect = gRegRect*2. - 1.;
    rect.yw *= -1.;

    uv.xy = (vid.xx == uint2(2,1))? (2.).xx:(0).xx;
    rect  = float4( lerp(rect.xy, rect.zw, uv.xy) ,0,1);
    uv.zw = uv.xy * float2(4,2);         // cursor pos id
    uv.xy = uv.xy * float2(20, 12) - .5; // 4x5 -> 5x6 with padding. (5x6)*(4x2)
    uv.z  = 4. - uv.z;                   // flip cursor pos
    return rect;
}

float4 ps_debug( float4 vpos : SV_POSITION, float4 uv : TEXCOORD ) : SV_TARGET {
    uv.xy %= float2(5,6);
    uint4 iuv = uv;
    return (all( 0 <= uv.xy  && uv.xy < float2(4,5) ) && (uv.z > 0) && (uv.w < 2)) ?
        (charSprites[LOW4((iuv.w? OPB():CP()) >> (iuv.z*4))*5 + iuv.y] >> (7-iuv.x))%2:0;
    // had to use OPB cause memory is already updated by write()
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  techniques
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//supposedly should run at 60Hz
technique chip8 {

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Main Loop (single cycle per frame)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    pass run {
        PrimitiveTopology   = POINTLIST;    // 1 for passing working op,
        VertexCount         = 5;            // 2 for instruction, 1 for CP, 1 for timer.
        VertexShader        = vs_run;       // readA writeB
        PixelShader         = ps_run;
        RenderTarget        = texRegB;
    }
//  memory -> register
    pass read {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_read;      // MEM -> REG
        PixelShader         = ps_read;
        RenderTarget        = texRegB;
    }
//  register -> memory:  init(), _mem_dump(), _mem_bcd()
    pass write {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_write;     // REG -> MEM
        PixelShader         = ps_write;
        RenderTarget        = texMem;       // doesn't hanve mem-mem access
    }
//  display update disp()/disp_clear()
    pass draw {                             // render quad on buffer
        PrimitiveTopology   = TRIANGLESTRIP;
        VertexCount         = 4;
        VertexShader        = vs_draw;      // either disp() or disp_clear()
        PixelShader         = ps_draw;      // read texA, texFront, texMem
        RenderTarget        = texBack;
    }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Write Back
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    pass lineCopy {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_lineCopy;
        PixelShader         = ps_lineCopy;
        RenderTarget        = texRegA;
    }
    pass copy {
        VertexShader        = vs_copy;
        PixelShader         = ps_copy;
        RenderTarget        = texFront;
    }

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Main Loop (single cycle per frame)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    pass run {
        PrimitiveTopology   = POINTLIST;    // 1 for passing working op,
        VertexCount         = 5;            // 2 for instruction, 1 for CP, 1 for timer.
        VertexShader        = vs_run;       // readA writeB
        PixelShader         = ps_run;
        RenderTarget        = texRegB;
    }
//  memory -> register
    pass read {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_read;      // MEM -> REG
        PixelShader         = ps_read;
        RenderTarget        = texRegB;
    }
//  register -> memory:  init(), _mem_dump(), _mem_bcd()
    pass write {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_write;     // REG -> MEM
        PixelShader         = ps_write;
        RenderTarget        = texMem;       // doesn't hanve mem-mem access
    }
//  display update disp()/disp_clear()
    pass draw {                             // render quad on buffer
        PrimitiveTopology   = TRIANGLESTRIP;
        VertexCount         = 4;
        VertexShader        = vs_draw;      // either disp() or disp_clear()
        PixelShader         = ps_draw;      // read texA, texFront, texMem
        RenderTarget        = texBack;
    }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Write Back
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    pass lineCopy {
        PrimitiveTopology   = LINELIST;
        VertexCount         = 2;
        VertexShader        = vs_lineCopy;
        PixelShader         = ps_lineCopy;
        RenderTarget        = texRegA;
    }
    pass copy {
        VertexShader        = vs_copy;
        PixelShader         = ps_copy;
        RenderTarget        = texFront;
    }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  present
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    pass present {
        VertexShader        = vs_present;  // support custom texture,
        PixelShader         = ps_present;  // tint, and transparency
        BlendEnable         = true;
        SrcBlend            = SRCALPHA;
        DestBlend           = INVSRCALPHA;
    }
    pass status {                           // morgh beteen red square or
        VertexShader        = vs_status;    // green triangle.
        PixelShader         = ps_status;    // red circle when debugging.
        BlendEnable         = true;
        SrcBlend            = SRCALPHA;
        DestBlend           = INVSRCALPHA;
    }
    pass debug {
        VertexShader        = vs_debug;     // shows cp & op
        PixelShader         = ps_debug;
        BlendEnable         = true;
        SrcBlend            = SRCALPHA;
        DestBlend           = INVSRCALPHA;
    }

}

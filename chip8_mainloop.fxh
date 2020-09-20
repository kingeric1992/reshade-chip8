//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Main Loop (single cycle per frame)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    pass run {
        PrimitiveTopology   = POINTLIST;    // 1 for passing working op,
        VertexCount         = 4;            // 2 for instruction, 1 for CP
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
import { Controller, Get, Post, Body, Param, Query } from '@nestjs/common';
import { TxService } from './tx.service';
import { CreateTxJobDto } from './dto/create-tx-job.dto';

@Controller('tx')
export class TxController {
  constructor(private readonly txService: TxService) {}

  @Post()
  async create(@Body() createTxJobDto: CreateTxJobDto) {
    return this.txService.create(createTxJobDto);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.txService.findOne(id);
  }

  @Get()
  async findAll(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('fromChainId') fromChainId?: string,
    @Query('toChainId') toChainId?: string,
    @Query('status') status?: string,
  ) {
    return this.txService.findAll({
      page: Number(page),
      limit: Number(limit),
      fromChainId: fromChainId ? parseInt(fromChainId) : undefined,
      toChainId: toChainId ? parseInt(toChainId) : undefined,
      status,
    });
  }
}

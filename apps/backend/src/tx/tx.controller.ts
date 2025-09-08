import { Controller, Post, Body, Get, Param, NotFoundException, Query } from '@nestjs/common';
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
    const txJob = await this.txService.findOne(id);
    if (!txJob) {
      throw new NotFoundException(`Transaction job with ID ${id} not found`);
    }
    return txJob;
  }

  @Get()
  async findAll(
    @Query('page') page = '1',
    @Query('limit') limit = '10',
    @Query('fromChainId') fromChainId?: string,
    @Query('toChainId') toChainId?: string,
    @Query('status') status?: string,
  ) {
    const pageNumber = parseInt(page, 10);
    const limitNumber = parseInt(limit, 10);
    
    return this.txService.findAll({
      page: pageNumber,
      limit: limitNumber,
      fromChainId: fromChainId ? parseInt(fromChainId, 10) : undefined,
      toChainId: toChainId ? parseInt(toChainId, 10) : undefined,
      status,
    });
  }
}

import { Controller, Post, Body } from '@nestjs/common';
import { TxService } from './tx.service';
import { CreateTxDto } from './dto/create-tx.dto';

@Controller('tx')
export class TxController {
  constructor(private readonly txService: TxService) {}

  @Post()
  create(@Body() createTxDto: CreateTxDto) {
    return this.txService.createTxJob(createTxDto);
  }
}

import { IsInt, IsObject, IsNotEmpty, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateTxDto {
  @IsInt()
  @Min(1)
  @Type(() => Number)
  fromChainId!: number;

  @IsInt()
  @Min(1)
  @Type(() => Number)
  toChainId!: number;

  @IsObject()
  @IsNotEmpty()
  payload!: any;
}

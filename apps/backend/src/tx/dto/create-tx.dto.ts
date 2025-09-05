import { IsInt, IsObject } from 'class-validator';

export class CreateTxDto {
  @IsInt()
  fromChainId: number;

  @IsInt()
  toChainId: number;

  @IsObject()
  payload: Record<string, any>;
}

import { TxPayload } from './tx-payload.interface'; // vagy ahonnan jön

export class CreateTxDto {
  fromChainId!: number;
  toChainId!: number;
  payload!: TxPayload;
}
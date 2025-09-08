export class CreateTxJobDto {
  fromChainId: number;
  toChainId: number;
  payload: {
    type: string;
    to: string;
    amount: string;
    [key: string]: any;
  };
}

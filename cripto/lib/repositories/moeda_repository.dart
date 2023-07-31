import '../models/moeda.dart';

class MoedaRepository {
  static List<Moeda> tabela = [
    Moeda(
        icone: 'images/bitcoin.png',
        nome: 'Bitcoin',
        sigla: 'BTC',
        preco: 138647.54),
    Moeda(
        icone: 'images/ethereum.png',
        nome: 'Ethereum',
        sigla: 'ETH',
        preco: 8797.56),
    Moeda(icone: 'images/xrp.png', nome: 'XRP', sigla: 'XRP', preco: 3.33),
    Moeda(
        icone: 'images/cardano.png',
        nome: 'Cardano',
        sigla: 'ADA',
        preco: 1.44),
    Moeda(
        icone: 'images/litecoin.png',
        nome: 'Litecoin',
        sigla: 'LTC',
        preco: 424.72),
    Moeda(
        icone: 'images/usdcoin.png',
        nome: 'USD Coin',
        sigla: 'USDC',
        preco: 26.64),
  ];

  MoedaRepository();
}

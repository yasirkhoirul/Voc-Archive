export interface ExchangeRate {
  usd_to_idr: number;
  updated_at: FirebaseFirestore.Timestamp;
}

export interface ShippingRate {
  nama_area: string;
  harga: number;
}

export interface ShippingRatesDoc {
  rates: ShippingRate[];
  updated_at: FirebaseFirestore.Timestamp;
}

export interface SetExchangeRateInput {
  usd_to_idr: number;
}

export interface AddShippingRateInput {
  nama_area: string;
  harga: number;
}

export interface UpdateShippingRateInput {
  nama_area: string;
  harga: number;
}

export interface DeleteShippingRateInput {
  nama_area: string;
}

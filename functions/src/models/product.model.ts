export type SizeKey = "onesize" | "xs" | "s" | "m" | "l" | "xl" | "xxl";

export interface Product {
  uid: string;
  gambar: string[];
  gambar_paths: string[];
  nama_brand: string;
  harga: number;
  deskripsi: string;
  detail: string;
  sizes: Record<SizeKey, number>;
  total_stok: number;
  diskon: number;
  harga_diskon: number;
  created_at: FirebaseFirestore.Timestamp;
  updated_at: FirebaseFirestore.Timestamp;
}

export interface CreateProductInput {
  gambar_base64: string[];
  nama_brand: string;
  harga: number;
  deskripsi: string;
  detail: string;
  sizes: Record<string, number>;
  diskon?: number;
}

export interface UpdateProductInput {
  uid: string;
  gambar_base64?: string[];
  nama_brand?: string;
  harga?: number;
  deskripsi?: string;
  detail?: string;
  sizes?: Record<string, number>;
  diskon?: number;
}

export interface UpdateStockInput {
  uid: string;
  /** Map of size key to stock change (positive to add, negative to subtract) */
  stock_changes: Record<string, number>;
}

export interface DeleteProductInput {
  uid: string;
}

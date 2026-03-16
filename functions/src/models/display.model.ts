export interface DisplayItem {
  uid: string;
  judul: string;
  product_ids: string[];
  created_at: FirebaseFirestore.Timestamp;
  updated_at: FirebaseFirestore.Timestamp;
}

export interface CreateDisplayInput {
  judul: string;
  product_ids: string[];
}

export interface UpdateDisplayInput {
  uid: string;
  judul?: string;
  product_ids?: string[];
}

export interface DeleteDisplayInput {
  uid: string;
}

export interface Brand {
  uid: string;
  nama: string;
  created_at: FirebaseFirestore.Timestamp;
}

export interface CreateBrandInput {
  nama: string;
}

export interface UpdateBrandInput {
  uid: string;
  nama: string;
}

export interface DeleteBrandInput {
  uid: string;
}

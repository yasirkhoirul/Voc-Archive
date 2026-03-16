export interface Slider {
  uid: string;
  judul: string;
  deskripsi: string;
  gambar: string;
  gambar_path: string;
  created_at: FirebaseFirestore.Timestamp;
}

export interface CreateSliderInput {
  judul: string;
  deskripsi: string;
  gambar_base64: string;
}

export interface DeleteSliderInput {
  uid: string;
}

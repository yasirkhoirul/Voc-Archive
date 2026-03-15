export interface Address {
    country: string;
    city: string;
    postal_code: string;
    address_detail: string;
}

export interface UserProfile {
    uid: string;
    email: string;
    nama: string;
    phone: string;
    address: Address;
    role: "user" | "admin";
    created_at: FirebaseFirestore.Timestamp;
    updated_at: FirebaseFirestore.Timestamp;
}

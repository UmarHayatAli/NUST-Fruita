// ENUM values and regexes shared by the server and the web app.
// They must match the MySQL ENUMs and CHECKs in spec section 7 exactly.

export const ROLES = ['CUSTOMER', 'ADMIN', 'RIDER'];
export const USER_TYPES = ['STUDENT', 'STAFF', 'EXTERNAL'];
export const USER_STATUSES = ['ACTIVE', 'BLOCKED'];
export const UNITS = ['KG', 'DOZEN', 'PIECE'];
export const ADDRESS_TYPES = ['HOSTEL', 'HOME'];
export const GENDER_TYPES = ['MALE', 'FEMALE'];
export const ORDER_STATUSES = [
  'PLACED',
  'CONFIRMED',
  'PACKED',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
];
export const DELIVERY_STATUSES = ['ASSIGNED', 'PICKED_UP', 'DELIVERED', 'FAILED'];
export const PAYMENT_STATUSES = ['PENDING', 'COLLECTED', 'CANCELLED'];

// Same pattern as CHECK ck_orders_whatsapp (BR7) and the phone rule in F01.
export const PHONE_REGEX = /^(03[0-9]{9}|\+923[0-9]{9})$/;

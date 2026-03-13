const mongoose = require('mongoose');

const carSchema = new mongoose.Schema({
  name: { type: String, required: true },
  brand: { type: String, required: true },
  model: { type: String, required: true },
  year: { type: Number, required: true },
  type: { type: String, enum: ['Sedan', 'SUV', 'Sports', 'Supercar', 'Hatchback', 'Convertible', 'Truck', 'Van'], required: true },
  transmission: { type: String, enum: ['Automatic', 'Manual', 'CVT'], required: true },
  fuel: { type: String, enum: ['Petrol', 'Diesel', 'Electric', 'Hybrid'], required: true },
  seats: { type: Number, required: true },
  pricePerDay: { type: Number, required: true },
  location: { type: String, required: true },
  available: { type: Boolean, default: true },
  features: [{ type: String }],
  images: [{ type: String }],
  rating: { type: Number, default: 0, min: 0, max: 5 },
  totalRatings: { type: Number, default: 0 },
  description: { type: String, default: '' },
  mileage: { type: String, default: 'Unlimited' },
  insurance: { type: Boolean, default: true },
}, { timestamps: true });

carSchema.index({ brand: 1, type: 1, available: 1, pricePerDay: 1 });

module.exports = mongoose.model('Car', carSchema);

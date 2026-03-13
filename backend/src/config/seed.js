require('dotenv').config({ path: '../../../.env' });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const connectDB = async () => {
  await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/carrento');
  console.log('Connected to MongoDB');
};

const UserSchema = new mongoose.Schema({ name: String, email: String, password: String, role: String, phone: String, createdAt: { type: Date, default: Date.now } });
const CarSchema = new mongoose.Schema({
  name: String, brand: String, model: String, year: Number, type: String,
  transmission: String, fuel: String, seats: Number, pricePerDay: Number,
  location: String, available: { type: Boolean, default: true },
  features: [String], images: [String], rating: Number, totalRatings: Number,
  description: String, createdAt: { type: Date, default: Date.now }
});

const User = mongoose.models.User || mongoose.model('User', UserSchema);
const Car = mongoose.models.Car || mongoose.model('Car', CarSchema);

const seed = async () => {
  await connectDB();
  await User.deleteMany({});
  await Car.deleteMany({});

  const hashedPassword = await bcrypt.hash(process.env.ADMIN_PASSWORD || 'Admin@123456', 12);
  await User.create({
    name: process.env.ADMIN_NAME || 'Super Admin',
    email: process.env.ADMIN_EMAIL || 'admin@carrento.com',
    password: hashedPassword,
    role: 'admin',
    phone: '+1234567890'
  });

  const cars = [
    { name: 'Tesla Model S', brand: 'Tesla', model: 'Model S', year: 2023, type: 'Sedan', transmission: 'Automatic', fuel: 'Electric', seats: 5, pricePerDay: 150, location: 'New York', features: ['Autopilot', 'Premium Sound', 'Heated Seats', 'WiFi', 'Supercharging'], images: ['https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800'], rating: 4.9, totalRatings: 128, description: 'Experience the future of driving with Tesla Model S. Ludicrous acceleration meets premium luxury.' },
    { name: 'BMW M3 Competition', brand: 'BMW', model: 'M3', year: 2023, type: 'Sports', transmission: 'Automatic', fuel: 'Petrol', seats: 4, pricePerDay: 180, location: 'Los Angeles', features: ['M Sport', 'Carbon Fiber', 'Harman Kardon', 'Head-Up Display', 'Adaptive Suspension'], images: ['https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800'], rating: 4.8, totalRatings: 96, description: 'Track-bred performance for the road. The M3 Competition delivers raw, unfiltered driving emotion.' },
    { name: 'Range Rover Sport', brand: 'Land Rover', model: 'Range Rover Sport', year: 2023, type: 'SUV', transmission: 'Automatic', fuel: 'Hybrid', seats: 7, pricePerDay: 220, location: 'Miami', features: ['Terrain Response', 'Pano Roof', 'Meridian Sound', 'Air Suspension', 'Off-Road Capability'], images: ['https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800'], rating: 4.7, totalRatings: 74, description: 'Commanding presence meets supreme comfort. Conquer any terrain in absolute luxury.' },
    { name: 'Porsche 911 Carrera', brand: 'Porsche', model: '911 Carrera', year: 2022, type: 'Sports', transmission: 'Manual', fuel: 'Petrol', seats: 2, pricePerDay: 280, location: 'Chicago', features: ['Sport Chrono', 'PASM', 'Bose Sound', 'Sport Exhaust', 'Launch Control'], images: ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800'], rating: 5.0, totalRatings: 52, description: 'An icon reborn. The 911 Carrera defines sports car perfection with legendary precision.' },
    { name: 'Mercedes C-Class', brand: 'Mercedes', model: 'C300', year: 2023, type: 'Sedan', transmission: 'Automatic', fuel: 'Petrol', seats: 5, pricePerDay: 120, location: 'Houston', features: ['MBUX', 'Burmester Sound', 'LED Lights', 'Driver Assistance', 'Wireless Charging'], images: ['https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800'], rating: 4.6, totalRatings: 143, description: 'Refined elegance for every journey. The C-Class sets the standard for executive sedans.' },
    { name: 'Audi Q8', brand: 'Audi', model: 'Q8', year: 2023, type: 'SUV', transmission: 'Automatic', fuel: 'Petrol', seats: 5, pricePerDay: 200, location: 'Seattle', features: ['Matrix LED', 'Bang & Olufsen', 'Virtual Cockpit', 'Air Suspension', 'Quattro AWD'], images: ['https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800'], rating: 4.8, totalRatings: 88, description: 'Where SUV versatility meets coupe aesthetics. The Q8 is a statement of confident luxury.' },
    { name: 'Lamborghini Huracán', brand: 'Lamborghini', model: 'Huracán', year: 2022, type: 'Supercar', transmission: 'Automatic', fuel: 'Petrol', seats: 2, pricePerDay: 800, location: 'Las Vegas', features: ['V10 Engine', 'Carbon Ceramic Brakes', 'Lifting System', 'Sport Exhaust', 'Alcantara Interior'], images: ['https://images.unsplash.com/photo-1541348263662-e068662d82af?w=800'], rating: 5.0, totalRatings: 31, description: 'Raw Italian supercar fury. The Huracán delivers a visceral experience that defies description.' },
    { name: 'Toyota Camry', brand: 'Toyota', model: 'Camry', year: 2023, type: 'Sedan', transmission: 'Automatic', fuel: 'Hybrid', seats: 5, pricePerDay: 65, location: 'Phoenix', features: ['Toyota Safety Sense', 'Apple CarPlay', 'LED Headlights', 'Dual Climate', 'Wireless Charging'], images: ['https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800'], rating: 4.4, totalRatings: 217, description: 'Reliable, refined, and remarkably efficient. The Camry Hybrid is the smart choice for every trip.' }
  ];

  await Car.insertMany(cars);
  console.log('✅ Seeded admin user and 8 cars');
  console.log(`📧 Admin Email: ${process.env.ADMIN_EMAIL || 'admin@carrento.com'}`);
  console.log(`🔑 Admin Password: ${process.env.ADMIN_PASSWORD || 'Admin@123456'}`);
  process.exit(0);
};

seed().catch(err => { console.error(err); process.exit(1); });

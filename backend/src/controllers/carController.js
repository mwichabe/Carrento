const Car = require('../models/Car');
const Booking = require('../models/Booking');

exports.getCars = async (req, res) => {
  try {
    const { type, fuel, transmission, minPrice, maxPrice, location, seats, available, search, sortBy, page = 1, limit = 10 } = req.query;
    const filter = {};

    if (type) filter.type = type;
    if (fuel) filter.fuel = fuel;
    if (transmission) filter.transmission = transmission;
    if (location) filter.location = { $regex: location, $options: 'i' };
    if (seats) filter.seats = { $gte: parseInt(seats) };
    if (available !== undefined) filter.available = available === 'true';
    if (minPrice || maxPrice) filter.pricePerDay = {};
    if (minPrice) filter.pricePerDay.$gte = parseFloat(minPrice);
    if (maxPrice) filter.pricePerDay.$lte = parseFloat(maxPrice);
    if (search) filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { brand: { $regex: search, $options: 'i' } },
      { model: { $regex: search, $options: 'i' } }
    ];

    const sort = {};
    if (sortBy === 'price_asc') sort.pricePerDay = 1;
    else if (sortBy === 'price_desc') sort.pricePerDay = -1;
    else if (sortBy === 'rating') sort.rating = -1;
    else sort.createdAt = -1;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [cars, total] = await Promise.all([
      Car.find(filter).sort(sort).skip(skip).limit(parseInt(limit)),
      Car.countDocuments(filter)
    ]);

    res.json({ success: true, data: cars, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getCar = async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) return res.status(404).json({ success: false, message: 'Car not found.' });
    res.json({ success: true, data: car });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.createCar = async (req, res) => {
  try {
    const car = await Car.create(req.body);
    res.status(201).json({ success: true, data: car });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
};

exports.updateCar = async (req, res) => {
  try {
    const car = await Car.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!car) return res.status(404).json({ success: false, message: 'Car not found.' });
    res.json({ success: true, data: car });
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
};

exports.deleteCar = async (req, res) => {
  try {
    const car = await Car.findByIdAndDelete(req.params.id);
    if (!car) return res.status(404).json({ success: false, message: 'Car not found.' });
    res.json({ success: true, message: 'Car deleted.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.checkAvailability = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const conflict = await Booking.findOne({
      car: req.params.id,
      status: { $in: ['confirmed', 'active'] },
      $or: [{ startDate: { $lte: new Date(endDate) }, endDate: { $gte: new Date(startDate) } }]
    });
    res.json({ success: true, available: !conflict });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

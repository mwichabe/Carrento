const Booking = require('../models/Booking');
const Car = require('../models/Car');
const User = require('../models/User');

exports.createBooking = async (req, res) => {
  try {
    const { carId, startDate, endDate, pickupLocation, dropoffLocation, notes } = req.body;
    const car = await Car.findById(carId);
    if (!car) return res.status(404).json({ success: false, message: 'Car not found.' });
    if (!car.available) return res.status(400).json({ success: false, message: 'Car not available.' });

    const start = new Date(startDate);
    const end = new Date(endDate);
    const totalDays = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
    if (totalDays < 1) return res.status(400).json({ success: false, message: 'Minimum 1 day rental.' });

    const conflict = await Booking.findOne({
      car: carId,
      status: { $in: ['confirmed', 'active'] },
      $or: [{ startDate: { $lte: end }, endDate: { $gte: start } }]
    });
    if (conflict) return res.status(400).json({ success: false, message: 'Car already booked for these dates.' });

    const booking = await Booking.create({
      user: req.user._id, car: carId, startDate: start, endDate: end,
      totalDays, totalPrice: totalDays * car.pricePerDay,
      pickupLocation, dropoffLocation, notes, status: 'pending'
    });

    await User.findByIdAndUpdate(req.user._id, { $inc: { totalBookings: 1 } });
    await booking.populate(['user', 'car']);
    res.status(201).json({ success: true, data: booking });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getUserBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user._id }).populate('car').sort({ createdAt: -1 });
    res.json({ success: true, data: bookings });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).populate(['user', 'car']);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found.' });
    if (booking.user._id.toString() !== req.user._id.toString() && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Unauthorized.' });
    }
    res.json({ success: true, data: booking });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found.' });
    if (booking.user.toString() !== req.user._id.toString()) return res.status(403).json({ success: false, message: 'Unauthorized.' });
    if (['completed', 'cancelled'].includes(booking.status)) {
      return res.status(400).json({ success: false, message: 'Cannot cancel this booking.' });
    }
    booking.status = 'cancelled';
    booking.cancellationReason = req.body.reason || 'User requested cancellation';
    await booking.save();
    res.json({ success: true, data: booking });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getAllBookings = async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const filter = status ? { status } : {};
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [bookings, total] = await Promise.all([
      Booking.find(filter).populate(['user', 'car']).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
      Booking.countDocuments(filter)
    ]);
    res.json({ success: true, data: bookings, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateBookingStatus = async (req, res) => {
  try {
    const booking = await Booking.findByIdAndUpdate(req.params.id, { status: req.body.status }, { new: true }).populate(['user', 'car']);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found.' });
    res.json({ success: true, data: booking });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

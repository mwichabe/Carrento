const User = require('../models/User');
const Car = require('../models/Car');
const Booking = require('../models/Booking');

exports.getDashboardStats = async (req, res) => {
  try {
    const [totalUsers, totalCars, totalBookings, revenue, recentBookings, popularCars] = await Promise.all([
      User.countDocuments({ role: 'user' }),
      Car.countDocuments(),
      Booking.countDocuments(),
      Booking.aggregate([{ $match: { status: { $in: ['completed', 'active', 'confirmed'] } } }, { $group: { _id: null, total: { $sum: '$totalPrice' } } }]),
      Booking.find().populate(['user', 'car']).sort({ createdAt: -1 }).limit(5),
      Booking.aggregate([
        { $group: { _id: '$car', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 5 },
        { $lookup: { from: 'cars', localField: '_id', foreignField: '_id', as: 'car' } },
        { $unwind: '$car' }
      ])
    ]);

    const monthlyRevenue = await Booking.aggregate([
      { $match: { status: 'completed', createdAt: { $gte: new Date(new Date().setMonth(new Date().getMonth() - 6)) } } },
      { $group: { _id: { month: { $month: '$createdAt' }, year: { $year: '$createdAt' } }, revenue: { $sum: '$totalPrice' }, count: { $sum: 1 } } },
      { $sort: { '_id.year': 1, '_id.month': 1 } }
    ]);

    res.json({
      success: true,
      data: {
        totalUsers, totalCars, totalBookings,
        totalRevenue: revenue[0]?.total || 0,
        recentBookings, popularCars, monthlyRevenue,
        availableCars: await Car.countDocuments({ available: true }),
        pendingBookings: await Booking.countDocuments({ status: 'pending' })
      }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, role } = req.query;
    const filter = {};
    if (search) filter.$or = [{ name: { $regex: search, $options: 'i' } }, { email: { $regex: search, $options: 'i' } }];
    if (role) filter.role = role;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [users, total] = await Promise.all([
      User.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
      User.countDocuments(filter)
    ]);
    res.json({ success: true, data: users, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateUserRole = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, { role: req.body.role }, { new: true });
    if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found.' });
    user.isActive = !user.isActive;
    await user.save();
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const router = require('express').Router();
const { getDashboardStats, getUsers, updateUserRole, toggleUserStatus } = require('../controllers/adminController');
const { getAllBookings, updateBookingStatus } = require('../controllers/bookingController');
const { protect, adminOnly } = require('../middleware/auth');

router.use(protect, adminOnly);
router.get('/dashboard', getDashboardStats);
router.get('/users', getUsers);
router.put('/users/:id/role', updateUserRole);
router.put('/users/:id/toggle-status', toggleUserStatus);
router.get('/bookings', getAllBookings);
router.put('/bookings/:id/status', updateBookingStatus);

module.exports = router;

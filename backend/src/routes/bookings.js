const router = require('express').Router();
const { createBooking, getUserBookings, getBooking, cancelBooking, getAllBookings, updateBookingStatus } = require('../controllers/bookingController');
const { protect, adminOnly } = require('../middleware/auth');

router.use(protect);
router.post('/', createBooking);
router.get('/my', getUserBookings);
router.get('/:id', getBooking);
router.put('/:id/cancel', cancelBooking);
router.get('/', adminOnly, getAllBookings);
router.put('/:id/status', adminOnly, updateBookingStatus);

module.exports = router;

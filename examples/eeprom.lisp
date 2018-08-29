(load "~/quicklisp/setup")
(ql:quickload 'intel-hex)

(loop
   with res = (make-array 256 :element-type '(unsigned-byte 8) :fill-pointer 0)
   and src = (intel-hex:read-hex-from-file 128000 "sim.hex")
   for use in '#1=(t nil . #1#)
   for i from #x4200 to #x42ff
   for val = (aref src i)
   when use do (vector-push-extend val res)
   else do (assert (zerop val))
   finally
   (intel-hex:write-hex-to-file res "mem.hex" :if-exists :supersede))
